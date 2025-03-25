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
        guard (try? shellOut(to: "uname")) == PackageResources.kernelName else {
            print("Error: Kernel-binary mismatch! Please stop using WatchDuck and re-install the correct binary for your operating system!".color(.red))
            throw ExitCode(EXIT_FAILURE)
        }
    }

    // TODO: Check if there is already a WatchDuck Instance Running!
//    static func instanceCheck() throws {
//
//    }
}
