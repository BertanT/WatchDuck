/*
 PackageResources.swift
 Created on 11/3/24.
 
 Copyright (C) 2024, 2025 Mehmet Bertan Tarakcioglu
 
 This file is part of WatchDuck.
 
 WatchDuck is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 WatchDuck is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License along with WatchDuck.
 If not, see <https://www.gnu.org/licenses/>.
*/

import Foundation

/// Contains general-purpose static constants such as version information and predefined CLI output.
enum PackageResources {
    /// The human-readable description of the package
    static let name = "WatchDuck"

    // The name of the package used in the CLI to execute commands
    static let CLIName = "watchduck"

    /// The human readable description of the package
    static let abstract = "Lightweight web service monitor and static status page generator."

    /// The current Semantic Version of WatchDuck
    static let version = "v0.1.4"

    /// The current JSON API revision. This needs to match for a previous log file to be initialized.
    static let apiRevision = 0

    /// The homepage for WatchDuck
    static let packageURL = URL(staticString: "https://github.com/bertant/WatchDuck")

    /// The documentation URL for WatchDuck
    static let docsURL = URL(staticString: "https://github.com/bertant/WatchDuck/blob/master/README.md")

    /// A cute ASCII duck for use in the CLI
    static var asciiDuck: String {
                """
                    __
                ___( o)>
                \\ <_. )
                 `---´

                """.color(.yellow)
    }

    /// The banner printed at launch the of WatchDuck CLI. Contains a greeting and auto-updating package information based on ``PackageResources`` constants.
    static let wdBanner: String =
                """
                \("Welcome to \(name)!".color(.cyan, bold: true)) \(version.color(.magenta, bold: true))
                    \("__".color(.yellow))
                \("___( o)>".color(.yellow))   \(abstract)
                \("\\ <_. )".color(.yellow))        \("-> Code and Documentation:".color(.red)) \(packageURL) \("<-".color(.red))
                 \("`---´".color(.yellow))
                \("Made with love and passion using Swift.".color(.blue))
                \("Copyright (c) 2025 M. Bertan Tarakcioglu, under GNU AGPL v3.0.".color(.blue))

                """

    /// Array containing each `String` "frame" of the CLI loading indicator.
    static var spinnerFrames: [String] { [".  ", ".. ", "...", " ..", "  .", "   "] }

    static let wdBinaryPath = "/usr/local/bin/watchduck"
    static let sampleConfigSource = Bundle.module.staticURL(forResource: "wdconfig-sample", withExtension: "yml", subdirectory: "Configuration")

    #if os(macOS)
    static let humanReadablePlatformName = "macOS"
    static let kernelName = "Darwin"

    static let defaultConfigURL = URL(fileURLWithPath: "/Library/Application Support/watchduck/wdconfig.yml")

    static let serviceName = "com.bertant.watchduck"
    static let serviceFileSource = Bundle.module.staticURL(forResource: "com.bertant.watchduck", withExtension: "plist", subdirectory: "Configuration")
    static let serviceFileDest   = URL(fileURLWithPath: "/Library/LaunchDaemons/com.bertant.watchduck.plist")
    static let serviceInstallerExtraInstructions: String =
                """
                > You can toggle the WatchDuck background process at any time by turning it off in the GUI at System Settings -> General -> Login Items & Extensions.

                """
    #elseif os(Linux)
    static let humanReadablePlatformName = "Linux"
    static let kernelName = "Linux"

    static let defaultConfigURL = URL(fileURLWithPath: "/etc/watchduck/wdconfig.yml")

    static let serviceName = "watchduck.service"
    static let serviceFileSource = Bundle.module.staticURL(forResource: "watchduck.service", withExtension: nil, subdirectory: "Configuration")
    static let serviceFileDest   = URL(fileURLWithPath: "/etc/systemd/system/watchduck.service")
    static let serviceInstallerExtraInstructions: String =
                """
                > Make sure you have systemd installed and running!
                > You can disable the WatchDuck background process any time by executing "sudo systemctl disable --now watchduck.service".
                  Re-enable it by running "sudo systemctl enable --now watchduck.service".
                """
    #endif

    static let wdServiceInstallerBanner =
                """
                \("Welcome to \(name) System Service Installer!".color(.cyan, bold: true)) \(version.color(.magenta, bold: true))
                \("This will install WatchDuck as a system service to run it in the background as a system service at all times.".color(.yellow))

                \("!!! Please check the following before proceeding !!!".color(.red, bold: true))
                > WatchDuck will always use the configuration at \(defaultConfigURL.path) in system service mode.
                    A sample configuration will be created there if it does not exist. To learn more about how to edit the configuration, see \(docsURL).

                """
}
