/*
 WDLog.swift
 Created on 7/21/24.
 
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

// TODO: Update documentation with reference to sample documentation.

/// Stores, encodes, decodes, and validates WatchDuck logs, making up the API backbone. Can be initialized from a decoder, JSON file, or as an empty log.
///
/// A sample log file and WatchDuck REST API reference can be found at:
///
/// Initialization from decoder or a JSON file checks for logical errors (e.g. make sure the start date of an outage is not later than the end date). If validation fails, a ``WDLogError`` is thrown.
///
/// - Important: The API revision in the static constant ``PackageResources/apiRevision`` should be updated updated if any.
struct WDLog: Codable {
    /// Represents different types of logical errors that WDLog can have.
    enum WDLogError: LocalizedError {
        case incompatibleRevision, invalidDate

        var errorDescription: String? {
            switch self {
            case .invalidDate:
                return "The last update date seems to be set in the future!"
            case .incompatibleRevision:
                return "The API Revision found in the logs are incompatible with the current version of WatchDuck! Required: \(PackageResources.apiRevision)."
            }
        }
    }

    /// The current API revision used to encode JSON output. **Only edit / hard-code `apiRevision` at ``PackageResources`` when updating this!**
    private let apiRevision: Int
    /// The date of the latest log entry.
    private(set) var lastUpdate: Date
    /// A dictionary that maps the check name to WDStatus, containing all the log data. **All check names must be unique!**
    private(set) var statusList: [String: WDStatus]

    /// Initializes a previous log saved as JSON.
    ///
    /// - Parameters:
    ///     - config: The ``WDConfig`` object containing the JSON log file path.
    ///
    /// - Throws ``WDLogError`` where appropriate.
    init(config: WDConfig) throws {
        let jsonData = try Data(contentsOf: config.JSONOutputPath)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        self = try decoder.decode(Self.self, from: jsonData)

        if apiRevision != PackageResources.apiRevision {
            throw WDLogError.incompatibleRevision
        }

        if lastUpdate > Date() {
            throw WDLogError.invalidDate
        }

        self.clean(config: config)
    }

    /// Initializes an empty log.
    init() {
        self.lastUpdate = Date()
        self.statusList = [:]
        self.apiRevision = PackageResources.apiRevision
    }

    /// Filters the entire log to only keep status data for sites/services specified in the provided configuration.
    ///
    /// - Parameters:
    ///         - config: The configuration object containing the checks to be kept.
    mutating func clean(config: WDConfig) {
        let checkNames = config.checks.map { $0.reflection.name }
        statusList = statusList.filter { checkNames.contains($0.key) }
    }

    /// Record a website/service check result to the log.
    ///
    /// - Parameters
    ///     - config: The configuration object containing the check we want to record a status for.
    ///     - check: The check we want to record a status for.
    mutating func record(config: WDConfig, check: WDCheck, isUp: Bool) {
        let reflection = check.reflection

        // Append to a previous status record if the check exists, create a new status record if not.
        if statusList[reflection.name] != nil {
            // Could force unwrap, but being safe in case something gets messed up
            statusList[reflection.name]?.update(isUp: isUp, maxOutageLogs: config.maxOutageLogs)
        } else {
            statusList[reflection.name] = WDStatus(isUp: isUp, url: reflection.url)
        }

        lastUpdate = Date()
    }

    /// Writes the log data to a file in JSON format at the specified log file path in the input configuration.
    mutating func writeToFile(config: WDConfig) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

        let jsonData = try encoder.encode(self)

        try FileManager.default.createDirectory(at: config.JSONOutputPath.deletingLastPathComponent(), withIntermediateDirectories: true)
        try jsonData.write(to: config.JSONOutputPath, options: [.atomic])
    }
}
