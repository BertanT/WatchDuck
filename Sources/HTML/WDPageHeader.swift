/*
 WDPageHeader.swift
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

import Foundation
import Plot

// Header component of the website
struct WDPageHeader: Component {
    let siteTitle: String
    let supportURL: URL?

    var body: Component {
        Div {
            // Title and logo...
            Div {
                Image("./images/wdlogo.svg")
                    .attribute(named: "aria-hidden", value: "true")
                H1(siteTitle)
            }
            .class("header-title")

            // Nav bar (only has the "Get Support" button)
            Navigation {
                if let supportURL {
                    Link(url: supportURL) {
                        FileComponents.inlineSVG("questionmark")
                        Span("Get Support")
                            .class("button-text")
                            .attribute(named: "aria-hidden", value: "true")
                    }
                    .class("button")
                    .linkTarget(.blank)
                }
            }
            .class("header-nav")
        }
        .class("header-container")
    }
}
