/*
 HTTPResponseCodeCheck.swift
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

import Foundation

// Required for Linux compatibility
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// TODO: Enhance error messages
struct HTTPResponseCodeCheck: AnyWDCheck {
    private enum CodingKeys: String, CodingKey {
        case name, url, method, headers, body, timeout, retries, retryInterval, waitForConnectivity, responseRanges, keywords
    }

    enum CheckError: LocalizedError {
        case getWithBody, emptyResponseRanges, invalidTimeout, invalidRetryInterval, invalidResponseRange

        var errorDescription: String? {
            switch self {
            case .getWithBody:
                return "A check with a get request cannot have a body!"
            case .emptyResponseRanges:
                return "Found empty response code range array on response code check!"
            case .invalidTimeout:
                return "Invalid timeout for check! It must be a positive value up to 120 seconds."
            case .invalidRetryInterval:
                return "Invalid retry interval for check! It must be a positive value up to 300 seconds."
            case .invalidResponseRange:
                return "Found invalid response code range on response code check! All ranges must be between 0 and 999"
            }
        }
    }

    let name: String
    let url: URL
    let method: HTTPMethod?
    let headers: [String: String]?
    let body: String?
    private(set) var timeout: TimeInterval = 30
    private(set) var retries = 5
    private(set) var retryInterval: TimeInterval = 30
    private(set) var waitForConnectivity = true
    private(set) var responseRanges = [200...299]
    private(set) var keywords = [String]()

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(URL.self, forKey: .url)

        self.method = try container.decodeIfPresent(HTTPMethod.self, forKey: .method)
        self.headers = try container.decodeIfPresent([String: String].self, forKey: .headers)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)

        try container.assignIfPresent(TimeInterval.self, forKey: .timeout, to: &timeout)
        try container.assignIfPresent(Int.self, forKey: .retries, to: &retries)
        try container.assignIfPresent(TimeInterval.self, forKey: .retryInterval, to: &retryInterval)
        try container.assignIfPresent(Bool.self, forKey: .waitForConnectivity, to: &waitForConnectivity)
        try container.assignIfPresent([ClosedRange<Int>].self, forKey: .responseRanges, to: &responseRanges)
        try container.assignIfPresent([String].self, forKey: .keywords, to: &keywords)

        try Self.validateCheck(self)
    }

    static func validateCheck(_ check: Self) throws {
        guard check.body == nil || (check.method ?? .get) != .get else {
            throw CheckError.getWithBody
        }

        guard !check.responseRanges.isEmpty else {
            throw CheckError.emptyResponseRanges
        }

        guard check.timeout != 0 && (0...120).contains(check.timeout) else {
            throw CheckError.invalidTimeout
        }

        guard check.retryInterval != 0 && (0...300).contains(check.retryInterval) else {
            throw CheckError.invalidRetryInterval
        }

        guard check.responseRanges.allSatisfy({ (0...999).containsRange($0) }) else {
            throw CheckError.invalidResponseRange
        }
    }

    func runCheck() async -> Bool {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)

        request.httpMethod = method?.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body?.data(using: request.preferredTextEncoding)
        request.timeoutInterval = timeout
        request.httpShouldHandleCookies = false

        let configuration = URLSessionConfiguration.default

        #if os(macOS)
        configuration.waitsForConnectivity = waitForConnectivity  // TODO: Only on macOS... Find a way on linux
        #endif

        let session = URLSession(configuration: configuration)

        guard let (data, response) = try? await session.retryingData(for: request, retries: retries, retryInterval: retryInterval) else {
            return false
        }

        // swiftlint: disable force_cast
        let httpResponse = response as! HTTPURLResponse
        // swiftlint: enable force_cast
        let responseText = String(data: data, encoding: httpResponse.textEncoding ?? .utf8)

        guard responseRanges.contains(where: { $0 ~= httpResponse.statusCode }) else {
            return false
        }

        guard keywords.allSatisfy({ responseText?.contains($0) ?? false }) else {
            return false
        }

        return true
    }
}
