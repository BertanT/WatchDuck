/*
 ServiceUninstall.swift
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

struct ServiceUninstall: ParsableCommand {
    static let configuration = CommandConfiguration(abstract:
        """
            Reverse the actions done by the service-install command to remove the system service installation from your computer.
        After running this command, WatchDuck will no longer run in the background and update itself automatically. Must be run as root.
        """)

    @Flag(name: [.customShort("y")], help: "Bypass the confirmation prompt to proceed with the uninstall.")
    var acceptDefault = false

    mutating func run() throws {
        try OSUtils.kernelCheck()
        try OSUtils.rootCheck()
        try OSUtils.pathCheck()

        print(PackageResources.asciiDuck)
        print(PackageResources.serviceUninstallBanner)

        if !acceptDefault {
            print("Would you like to proceed with uninstall? [Y/n]")
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

        print("> Disabling and removing the system service...".color(.magenta))
        #if os(macOS)
        _ = try? shellOut(to: "launchctl remove \(PackageResources.serviceName)")
        #elseif os(Linux)
        _ = try? shellOut(to: [
            "systemctl stop \(PackageResources.serviceName)",
            "systemctl disable \(PackageResources.serviceName)"
        ])
        #endif

        print("> Cleaning any configuration files...".color(.magenta))
        _ = try? shellOut(to: "rm \(PackageResources.serviceFileDest.path)")
        
        print("\n✔ The WatchDuck system service is now uninstalled.".color(.green, bold: true))
    }
}
