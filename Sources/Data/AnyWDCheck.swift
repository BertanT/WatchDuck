/*
 AnyWDCheck.swift
 Created on 7/7/24.
 
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

/// Represents a WatchDuck check of any type.
///
/// - Important: All new check types (such as ``HTTPResponseCodeCheck``) must
///  conform to this protocol!
protocol AnyWDCheck: Decodable {
    associatedtype CheckError: LocalizedError

    /// The name of the check.
    var name: String { get }

    /// The destination URL of the web service to be checked.
    var url: URL { get }

    /// Ensures a check can be run by validating its property values.
    /// - Throws: An `Error` specific to each check type on validation failure.
    static func validateCheck(_ check: Self) throws

    /// Asynchronous function that runs the web service check.
    /// - Returns: Boolean representing whether the web service is online.
    func runCheck() async -> Bool
}
