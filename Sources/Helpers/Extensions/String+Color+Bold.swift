/*
 String+Color+Bold.swift
 Created on 7/14/24.
 
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

extension String {
    func color(_ color: ANSIColors, bold: Bool = false) -> String {
        "\u{001B}[\(NSNumber(value: bold));\(color.rawValue)m\(self)\u{001B}[0;0m"
    }

    func bold() -> String {
        "\u{1B}[1m\(self)\u{1B}[0m"
    }
}
