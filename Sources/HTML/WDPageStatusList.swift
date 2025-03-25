/*
 WDPageStatusList.swift
 Created on 11/3/24.
 
 Copyright (C) 2024, 2025 Mehmet Bertan Tarakcioglu
 
 This file is part of WatchDuck.
 
 WatchDuck is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 WatchDuck is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License along with WatchDuck.
 If not, see <https://www.gnu.org/licenses/>.
*/

// swiftlint: disable closure_body_length
import Foundation
import Plot

struct WDPageStatusList: Component {
    let logs: [String: WDStatus]

    var body: Component {
        Element(name: "section") {
            for (name, status) in logs.sorted(by: { $0.key < $1.key }) {
                let id = UUID().uuidString

                Element(name: "section") {
                    Input(type: .checkbox)
                        .class("toggle")
                        .id(id)

                    Label("") {
                        FileComponents.inlineSVG("arrow")
                        H2(name)
                    }
                    .class("toggle-label")
                    .attribute(named: "for", value: id)

                    H3(status.isUp ? "Online" : "Down")
                        .class("\(status.isUp ? "up" : "down")-badge")

                    Div {
                        Div {
                            H5 {
                                Text("Target: ")
                                Link(status.url.absoluteString, url: status.url)
                                    .linkTarget(.blank)
                            }

                            if !status.outages.isEmpty {
                                H5("Recent Outages:")
                                List {
                                    for outage in status.outages {
                                        if let end = outage.end {
                                            ListItem("\(outage.start.formatted()) - \(end.formatted())")
                                        } else {
                                            ListItem("Down since \(outage.start.formatted())")
                                        }
                                    }
                                }
                            }
                        }
                        .class("status-details")
                    }
                    .class("status-details-wrapper")
                }
                .class("status")
            }
        }
        .class("status-list")
    }
}
// swiftlint: enable closure_body_length
