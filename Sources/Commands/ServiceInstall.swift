/*
 ServiceInstall.swift
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
import ShellOut

struct ServiceInstall: ParsableCommand {
    static let configuration = CommandConfiguration(abstract:
        """
            Configure launchd on macOS and systemd on Linux to automatically start and run WatchDuck in the background as a system service. Must be run as root.
        """)

    @Flag(name: [.customShort("y")], help: "Bypass the confirmation prompt to proceed with the installation.")
    var acceptDefault = false

    mutating func run() throws {
        try OSUtils.kernelCheck()
        try OSUtils.rootCheck()
        try OSUtils.pathCheck()

        print(PackageResources.asciiDuck)
        print(PackageResources.serviceInstallBanner)
        print(PackageResources.serviceInstallExtraInstructions)

        if !acceptDefault {
            print("Would you like to proceed with the installation? [Y/n]")
            if !["y", "yes"].contains(readLine()?.lowercased()) {
                print("Aborted by user!".color(.red))
                throw ExitCode(EXIT_FAILURE)
            }
            print()
        }

        #if os(Linux)
        print("> Checking if systemd is installed".color(.magenta))
        try OSUtils.systemdCheck()
        #endif

        print("> Trying to clean any previous installations...".color(.magenta))
        #if os(macOS)
        _ = try? shellOut(to: "launchctl remove \(PackageResources.serviceName)")
        #elseif os(Linux)
        _ = try? shellOut(to: [
            "systemctl stop \(PackageResources.serviceName)",
            "systemctl disable \(PackageResources.serviceName)"
        ])
        #endif
        _ = try? shellOut(to: "rm \(PackageResources.serviceFileDest.path)")

        print("> Copying system service configuration file...".color(.magenta))
        try FileManager.default.createDirectory(at: PackageResources.serviceFileDest.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(contentsOf: PackageResources.serviceFileSource).write(to: PackageResources.serviceFileDest, options: [.atomic])

        print("> Starting \(PackageResources.serviceName) and enabling it on boot.".color(.magenta))
        #if os(macOS)
        try shellOut(to: [
            "chown root \(PackageResources.serviceFileDest.path)",
            "launchctl bootstrap system/ \(PackageResources.serviceFileDest.path)"
        ])
        #elseif os(Linux)
        try shellOut(to: [
            "systemctl daemon-reload",
            "systemctl start watchduck",
            "systemctl enable watchduck"
        ])
        #endif

        if !FileManager.default.fileExists(atPath: PackageResources.defaultConfigURL.path) {
            print("> Creating sample configuration file at \(PackageResources.defaultConfigURL.path)...".color(.magenta))
            try FileManager.default.createDirectory(at: PackageResources.defaultConfigURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: PackageResources.sampleConfigSource, to: PackageResources.defaultConfigURL)
        }

        print("\n✔ All done! WatchDuck is now running and enabled at boot.".color(.green, bold: true))
    }
}
