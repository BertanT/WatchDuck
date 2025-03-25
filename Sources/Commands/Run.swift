/*
 Run.swift
 Created on 1/31/25.
 
 Copyright (C) 2025 Mehmet Bertan Tarakcioglu
 
 This file is part of WatchDuck.
 
 WatchDuck is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 WatchDuck is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License along with WatchDuck.
 If not, see <https://www.gnu.org/licenses/>.
*/

import ArgumentParser
import Foundation

struct Run: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Runs checks to update logs and the static webpage.")

    @Option(
        name: [.short, .customLong("config")],
        help: "The configuration JSON file path.",
        transform: URL.init(fileURLWithPath:))
    private var configURL = PackageResources.defaultConfigURL

    @Flag(
        name: [.customShort("o"), .customLong("once")],
        help: "Runs WatchDuck only once and exists instead of looping indefinitely with the interval specified in the configuration file."
    )
    private var runOnce = false

    mutating func run() async throws {
        try OSUtils.kernelCheck()

        let configuration: WDConfig
        var spinner = CLISpinner()

        // TODO: Make signal handling more elegant while keeping it secure if possible.
        signal(SIGINT, SIG_IGN)

        let sigintSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: DispatchQueue.main)

        sigintSource.setEventHandler {
            print("\nThank you for using WatchDuck :)".color(.cyan))
            Self.exit()
        }

        sigintSource.resume()

        print(PackageResources.wdBanner)

        print(">>> WatchDuck is in \(runOnce ? "single-run" : "system service") mode! <<<".color(.magenta, bold: true))

        spinner.start("Initializing configuration")
        do {
            configuration = try WDConfig(configURL: configURL)
            await spinner.stop("Initialized configuration!", result: .success)
        } catch {
            await spinner.stop("Configuration Error: \(error.lastUnderlyingErrorDescription)", result: .failure)
            throw ExitCode(EXIT_FAILURE)
        }

        if runOnce {
            try await executeAllChecks(configuration: configuration, spinner: &spinner)
            print()
        } else {
            while true {
                try await executeAllChecks(configuration: configuration, spinner: &spinner)

                print(" Sleeping until the next refresh in ~\(Int(configuration.refreshInterval.rounded()))s.".color(.blue, bold: true))
                try await Task.sleep(interval: configuration.refreshInterval)
            }
        }

        print("\nThank you for using WatchDuck :)".color(.cyan))
    }

    mutating func executeAllChecks(configuration: WDConfig, spinner: inout CLISpinner) async throws {
        var logs: WDLog

        print("\n> Checks started:".color(.magenta, bold: true))

        spinner.start("Looking for previous logs.")

        do {
            logs = try WDLog(config: configuration)
            await spinner.stop("Initialized previous JSON logs.", result: .success)
        } catch {
            if (error as NSError).code == NSFileReadNoSuchFileError {
                await spinner.stop("New JSON logs will be created at: \(configuration.JSONOutputPath.path)", result: .success)
            } else {
                if configuration.overwriteCorruptLogs {
                    await spinner.stop("Logs in file \(configuration.JSONOutputPath.path) are corrupted and will be overwritten!", result: .warning)
                    print("  Log File Error: \(error.lastUnderlyingErrorDescription)\n".color(.red))
                    print("  * Press 'Control + C' in the next 10 seconds to exit and cancel this operation now!".color(.red))
                    print("  * To change this behavior, set overwriteCorruptLogs to false in the configuration.".color(.yellow))
                    try await Task.sleep(interval: 10)
                } else {
                    await spinner.stop("Log File Error: \(error.lastUnderlyingErrorDescription)", result: .failure)
                    print("  * If you wish to ignore log file errors and overwrite them, set overwriteCorruptLogs to true in the configuration.".color(.yellow))
                    print("  Note that this will irreversibly delete any data present in said file!".color(.yellow))
                    throw ExitCode(EXIT_FAILURE)
                }
            }
            logs = WDLog()
        }

        spinner.start("Evaluating web services")
        await withTaskGroup(of: (WDCheck, Bool).self) { group in
            for check in configuration.checks {
                group.addTask {
                    (check, await check.reflection.runCheck())
                }

                for await result in group {
                    logs.record(config: configuration, check: result.0, isUp: result.1)
                }
            }
        }
        await spinner.stop("All services evaluated.", result: .success)

        spinner.start("Saving log file")
        do {
            try logs.writeToFile(config: configuration)
        } catch {
            await spinner.stop("Log file save error: \(error.lastUnderlyingErrorDescription)", result: .failure)
            throw ExitCode(EXIT_FAILURE)
        }
        await spinner.stop("Saved log file.", result: .success)

        if configuration.renderHTML {
            spinner.start("Generating static HTML")
            let html = WDHTML(config: configuration, log: logs)

            do {
                try html.saveHTMLFile()
            } catch {
                await spinner.stop("HTML file save error: \(error.lastUnderlyingErrorDescription)", result: .failure)
                throw ExitCode(EXIT_FAILURE)
            }

            await spinner.stop("Generated static HTML.", result: .success)
        }
        print("> Latest checks completed at \(logs.lastUpdate.formatted(date: .abbreviated, time: .complete)).".color(.blue, bold: true), terminator: "")
    }
}
