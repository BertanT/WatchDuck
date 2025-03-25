/*
 WDConfig.swift
 Created on 7/4/24.
 
 Copyright (C) 2024, 2025 Mehmet Bertan Tarakcioglu
 
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
import Yams

// TODO: Update documentation with reference to sample configuration.

/// Stores and validates all checks and configurations options for WatchDuck. Can only be initialized from a decoder or a YML file.
///
/// A sample configuration YML with a description for each option can be found at:
///
/// Initialization checks configuration values for any logical errors and reasonable limits (e.g. making sure the site title is not made up of whitespaces and the
/// maximum log count is not less than 2). If validation fails, a ``WDConfigError`` is thrown.
///
/// - Important: When implementing implementing new options, please make sure to also add any required validation logic to the ``validateConfig(_:)`` method.
/// Any new options should either be optional or have default values by design and be marked with `private(set)` for encapsulation.
struct WDConfig: Decodable {
    private enum CodingKeys: String, CodingKey {
        case refreshInterval, overwriteCorruptLogs, maxOutageLogs, JSONOutputPath, renderHTML, HTMLOutputDirectory, tryDefaultAssets
        case metaTitle, metaDescription, metaKeywords, metaAuthor, metaCopyright, metaLanguage, metaRobots, navHeaderTitle, supportURL, copyrightName, copyrightURL, contactURL, privacyPolicyURL

        case checks
    }

    /// Represents the different types of logical errors that configuration options can have
    enum WDConfigError: LocalizedError {
        case invalidRefreshInterval, noChecks, invalidOutageCount, duplicateCheckName

        var errorDescription: String? {
            switch self {
            case .invalidRefreshInterval:
                return "The refresh interval must be between 20 and 86400 seconds."
            case .noChecks:
                return "No checks found in the configuration!"
            case .invalidOutageCount:
                return "Maximum outage log count per check must be at least 2!"
            case .duplicateCheckName:
                return "One or more checks share the same name! All check names much be unique."
            }
        }
    }

    private(set) var refreshInterval: TimeInterval = 90

    /// ### Log settings

    /// Allows WatchDuck to delete and overwrite the JSON log file in its entirety if it contains invalid data or was encoded with an incompatible API version. True by default.
    private(set) var overwriteCorruptLogs = true

    /// The maximum number of outage incidents the logs store, including ongoing. When the limit is reached, adding a new incident deletes the oldest entry. `10` by default.
    private(set) var maxOutageLogs = 10

    /// The full output path for the JSON log file, including the filename and extension. Set to "./wdlogs.json" by default.
    private(set) var JSONOutputPath = URL(fileURLWithPath: "/wdlogs.json", isDirectory: false, relativeTo: .currentDirectory)

    /// ### HTML settings

    /// Controls whether WatchDuck generates a static HTML page. True by default.
    private(set) var renderHTML = true

    /// The directory path where the static HTML page and other website resources will live. Set to ./WDHTML by default.
    private(set) var HTMLOutputDirectory = URL(fileURLWithPath: "/WDHTML/", isDirectory: true, relativeTo: .currentDirectory)

    /// Controls whether WatchDuck tries to copy default stylesheets and website assets if they don't already exist in the directory. True by default.
    private(set) var tryDefaultAssets = true

    private(set) var metaTitle: String?
    private(set) var metaDescription: String?
    private(set) var metaKeywords: [String]?
    private(set) var metaAuthor: String = "WatchDuck"
    private(set) var metaCopyright: String?
    private(set) var metaLanguage: String = "EN"
    private(set) var metaRobots: String = "all"

    /// Specifies the website title reflected on the header and the tab title. `"WatchDuck Status"` by default.
    private(set) var navHeaderTitle: String = "WatchDuck Status"

    /// Shows a "Get Support" button in the header that links to the provided URL if set. `nil` by default.
    private(set) var supportURL: URL?

    /// Appends the specified text at the end of the copyright stamp in the footer followed by a space. `nil` by default.
    private(set) var copyrightName: String?

    /// If ``copyrightName`` is not `nil`, links its text to the specified URL in the footer.
    private(set) var copyrightURL: URL?

    /// Shows a "Contact" button at the footer navigation that links to the provided URL if set. `nil` by default.
    private(set) var contactURL: URL?

    /// Shows a "Privacy Policy" button at the footer navigation that links to the provided URL if set. `nil` by default.
    private(set) var privacyPolicyURL: URL?

    /// ### Checks
    /// The array of checks WatchDuck will process and run. Cannot be empty.
    private(set) var checks: [WDCheck]

    /// - Throws: ``WDConfigError`` if the configuration options' values contain logical errors.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try container.assignIfPresent(Bool.self, forKey: .overwriteCorruptLogs, to: &overwriteCorruptLogs)
        try container.assignIfPresent(Int.self, forKey: .maxOutageLogs, to: &maxOutageLogs)

        if let path = try container.decodeIfPresent(String.self, forKey: .JSONOutputPath),
            let url = URL(string: "file://" + path) {
                self.JSONOutputPath = url
        }

        // Put HTML into the same directory as the JSON feed by default
        // "./" at the end is to ensure everything works properly in Linux...
        HTMLOutputDirectory = JSONOutputPath.deletingLastPathComponent().appendingPathComponent("/.")

        if let path = try container.decodeIfPresent(String.self, forKey: .HTMLOutputDirectory),
            let url = URL(string: "file://" + path) {
                self.HTMLOutputDirectory = url
        }

        try container.assignIfPresent(TimeInterval.self, forKey: .refreshInterval, to: &refreshInterval)
        try container.assignIfPresent(Bool.self, forKey: .renderHTML, to: &renderHTML)
        try container.assignIfPresent(Bool.self, forKey: .tryDefaultAssets, to: &tryDefaultAssets)

        try container.assignIfPresent(String.self, forKey: .metaTitle, to: &metaTitle)
        try container.assignIfPresent(String.self, forKey: .metaDescription, to: &metaDescription)
        try container.assignIfPresent([String].self, forKey: .metaKeywords, to: &metaKeywords)
        try container.assignIfPresent(String.self, forKey: .metaAuthor, to: &metaAuthor)
        try container.assignIfPresent(String.self, forKey: .metaCopyright, to: &metaCopyright)
        try container.assignIfPresent(String.self, forKey: .metaLanguage, to: &metaLanguage)
        try container.assignIfPresent(String.self, forKey: .metaRobots, to: &metaRobots)

        try container.assignIfPresent(String.self, forKey: .metaTitle, to: &navHeaderTitle)
        try container.assignIfPresent(URL.self, forKey: .supportURL, to: &supportURL)
        try container.assignIfPresent(String.self, forKey: .copyrightName, to: &copyrightName)
        try container.assignIfPresent(URL.self, forKey: .copyrightURL, to: &copyrightURL)
        try container.assignIfPresent(URL.self, forKey: .contactURL, to: &contactURL)
        try container.assignIfPresent(URL.self, forKey: .privacyPolicyURL, to: &privacyPolicyURL)

        self.checks = try container.decode([WDCheck].self, forKey: .checks)

        try Self.validateConfig(self)
    }

    /// Creates a new instance by decoding and validating the contents of a YML file
    ///
    /// - Parameters:
    ///     - configURL: The URL path to the YML file to be decoded
    ///
    /// - Throws: ``WDConfigError`` if the configuration options' values contain logical errors.
    init(configURL: URL) throws {
        let ymlData = try Data(contentsOf: configURL)
        let decoder = YAMLDecoder()

        self = try decoder.decode(Self.self, from: ymlData)
    }

    /// Validates that the configuration options do not contain any logical errors.
    ///
    /// - Parameters:
    ///     - config: The configuration instance to be validated.
    ///
    /// - Throws: ``WDConfigError`` if the configuration options' values contain logical errors.
    static func validateConfig(_ config: Self) throws {
        if !(20...86_400).contains(config.refreshInterval) {
            throw WDConfigError.invalidRefreshInterval
        }

        guard !config.checks.isEmpty else {
            throw WDConfigError.noChecks
        }

        guard config.maxOutageLogs > 1 else {
            throw WDConfigError.invalidOutageCount
        }

        let checkNames = config.checks.map { $0.reflection.name }
        guard Set(checkNames).count == checkNames.count else {
            throw WDConfigError.duplicateCheckName
        }

        // TODO: Add checks for new configuration
    }
}
