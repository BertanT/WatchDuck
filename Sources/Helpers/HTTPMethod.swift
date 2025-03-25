/*
 HTTPMethod.swift
 Created on 7/10/24.
 
 Copyright (C) 2024, 2025 Mehmet Bertan Tarakcioglu
 
 This file is part of WatchDuck.
 
 WatchDuck is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 WatchDuck is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License along with WatchDuck.
 If not, see <https://www.gnu.org/licenses/>.
*/

enum HTTPMethod: String, CaseIterable, Decodable {
    case connect, delete, get, head, options, patch, post, put, trace

    var rawValue: String {
        let description = String(describing: self)
        return description.uppercased()
    }

    init?(rawValue: String) {
        guard let match = Self.allCases.first(where: { $0.rawValue == rawValue.uppercased() }) else {
            return nil
        }
        self = match
    }
}
