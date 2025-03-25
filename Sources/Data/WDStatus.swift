/*
 WDStatus.swift
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

/// Stores the current status, target site/service URL, and historical outage data as a ``WDOutage`` array for a ``WDCheck``.
struct WDStatus: Codable {
    private enum CodingKeys: CodingKey {
        case isUp, url, outages
    }

    private(set) var isUp: Bool
    let url: URL
    private(set) var outages: [WDOutage]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.url = try container.decode(URL.self, forKey: .url)
        self.outages = try container.decode([WDOutage].self, forKey: .outages)
            .uniqued()
            .sorted { $0.start > $1.start }

        if let latestOutage = outages.first {
            self.outages = outages.filter { outage in
                (outage.end != nil || outage == latestOutage) &&
                (outage.start < outage.end ?? .distantFuture) &&
                (outage.start < Date()) &&
                (outage.end ?? .distantPast < Date())
            }

            isUp = !latestOutage.isOngoing
        } else {
            // Has no previous outage data
            isUp = true
        }
    }

    init(isUp: Bool, url: URL) {
        self.isUp = isUp
        self.url = url
        self.outages = isUp ? [] : [WDOutage(start: Date(), end: nil)]
    }

    mutating func update(isUp newStatus: Bool, maxOutageLogs: Int) {
        if newStatus {
            if !isUp {
                // If it was down but came online...
                if var latestOutage = outages.first {
                    latestOutage.end = Date()
                    outages.removeFirst()
                    outages.insert(latestOutage, at: 0)
                }
            }
            // Do nothing if it was online and is still online
        } else {
            if isUp {
                // If it was online but came down
                outages.insert(WDOutage(start: Date(), end: nil), at: 0)
            }
            // Do nothing if it was down and is still down
        }

        // Update the old status before returning
        self.isUp = newStatus

        // Remove the oldest log if it is more than the current count
        if outages.count > maxOutageLogs {
            outages.removeLast()
        }
    }
}
