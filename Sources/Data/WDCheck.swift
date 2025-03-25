/*
 WDCheck.swift
 Created on 7/5/24.
 
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

/// A generalized enum that decodes and validates different WatchDuck check types from JSON.
///
/// Decoding is based on the check Type specified in JSON. A “type-erased” instance of ``AnyWDCheck`` is available via ``reflection``,
/// preserving the unique check procedure for each type while standardizing access. This allows seamless combination of Checks in
/// a `Sequence` and running them in a single loop.
///
/// Initialization from the decoder validates ``AnyWDCheck/name`` and ``AnyWDCheck/url``. A ``WDCheckError`` is thrown on failure.
enum WDCheck: Decodable {
    case responseCode(HTTPResponseCodeCheck)

    /// Specifies the different types of checks WatchDuck can run. Used for decoding structs that conform to AnyWDCheck.
    private enum WDCheckType: String, Decodable {
        case responseCode
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }

    /// Represents different types of errors that any check Type can have.
    enum WDCheckError: LocalizedError {
        /// The case where the check name consists only of whitespaces.
        case invalidName

        var errorDescription: String {
            switch self {
            case .invalidName:
                return "Found invalid check name! Names cannot consist of whitespaces."
            }
            // TODO: Add URL validation
        }
    }

    /// The "type-erased" mirror of the check to a value of type AnyWDCheck.
    var reflection: any AnyWDCheck {
        guard let reflection = Mirror(reflecting: self).children.first?.value as? (any AnyWDCheck) else {
            // There is something wrong with the implementation if we are here...
            fatalError("Found member in enum WDCheck that does not conform to protocol AnyWDCheck! This is likely a bug. Please report it on \(PackageResources.packageURL)")
        }

        return reflection
    }

    /// - Throws: ``WDCheckError/invalidName`` if the name consists of whitespaces.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(WDCheckType.self, forKey: .type)

        let SVContainer = try decoder.singleValueContainer()

        switch type {
        case .responseCode:
            self = .responseCode(try SVContainer.decode(HTTPResponseCodeCheck.self))
        }

        try self.validateCheckRoot()
    }

    /// Validates values that all check types share.
    ///
    /// All check types are also required to implement their own validation function for all properties not covered in this method, as mandated in ``AnyWDCheck`` with ``AnyWDCheck/validateCheck(_:)``
    /// 
    /// - Throws: See ``WDCheck/init(from:)`` for all possible errors.
    func validateCheckRoot() throws {
        // TODO: Enhance the check, maybe check URL too
        let reflection = reflection

        guard !reflection.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw WDCheckError.invalidName
        }
    }
}
