/*
 OSUtils.swift
 Created on 2/21/25.
 
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

enum OSUtils {
    static func kernelCheck() throws {
        guard (try shellOut(to: "uname")) == PackageResources.kernelName else {
            print("Error: Kernel-binary mismatch! Please stop using WatchDuck and re-install the correct binary for your operating system!".color(.red))
            throw ExitCode(EXIT_FAILURE)
        }
    }

    static func rootCheck() throws {
        guard (try shellOut(to: "whoami")) == "root" else {
            print("Error: This command requires root privileges! Please try again using sudo.".color(.red))
            throw ExitCode(EXIT_FAILURE)
        }
    }

    static func pathCheck() throws {
        guard (try shellOut(to: "which \(PackageResources.CLIName)").lowercased()) == PackageResources.wdBinaryPath else {
            print("Error: The WatchDuck executable in your PATH must be located at \(PackageResources.wdBinaryPath) to proceed!".color(.red))
            throw ExitCode(EXIT_FAILURE)
        }

        guard Bundle.main.executablePath?.lowercased() == PackageResources.wdBinaryPath else {
            print("Error: This instance of WatchDuck does not seem to originate from the executable set in your path. Unable to proceed.".color(.red))
            throw ExitCode(EXIT_FAILURE)
        }
    }

    static func systemdCheck() throws {
        guard let shellResponse = try? shellOut(to: "which systemd"), shellResponse.contains("systemd") else {
            print("Error: Could not find systemd on your computer. Please install it and try again!".color(.red))
            throw ExitCode(EXIT_FAILURE)
        }
    }

    // TODO: Check if there is already a WatchDuck Instance Running!
//    static func instanceCheck() throws {
//
//    }
}
