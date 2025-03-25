/*
 Error+UnderlyingLocalizedDescription.swift
 Created on 7/20/24.
 
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

extension NSError {
    var lastUnderlyingErrorDescription: String {
        if let underlyingError = userInfo[NSUnderlyingErrorKey] as? NSError {
            return underlyingError.lastUnderlyingErrorDescription
        }

        return localizedDescription
    }
}

extension Error {
    var lastUnderlyingErrorDescription: String {
        (self as NSError).lastUnderlyingErrorDescription
    }
}
