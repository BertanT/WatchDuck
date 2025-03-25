/*
 URLSession+RetryingData.swift
 Created on 7/12/24.
 
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

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
    func retryingData(for request: URLRequest, retries: Int, retryInterval: TimeInterval, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {
        for _ in 0..<retries {
            do {
                return try await data(for: request, delegate: delegate)
            } catch {
                try? await Task.sleep(interval: retryInterval)
            }
        }
        return try await data(for: request, delegate: delegate)
    }
}
