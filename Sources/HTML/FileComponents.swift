/*
 FileComponents.swift
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

enum FileComponents {
    private static func getFileContents(url: URL, startMarker: any StringProtocol, endMarker: any StringProtocol, inclusiveBounds: Bool) -> Node<HTML.BodyContext> {
        guard let fileString = try? String(contentsOf: url, encoding: .utf8).replacingOccurrences(of: #"<!--(.*?)-->|\s\B"#, with: "", options: .regularExpression),
              let startMarkerRange = fileString.range(of: startMarker, options: .regularExpression),
              let endMarkerRange = fileString.range(of: endMarker, options: .regularExpression),
              startMarkerRange.upperBound <= endMarkerRange.lowerBound
        else {
            return .empty
        }

        let range = inclusiveBounds ? startMarkerRange.lowerBound..<endMarkerRange.upperBound :
            startMarkerRange.upperBound..<endMarkerRange.lowerBound

        return .raw(fileString[range].description)
    }

    static func rawHTML(url: URL) -> Node<HTML.BodyContext> {
        getFileContents(url: url, startMarker: #"<\s*html\b[^>]*>"#, endMarker: "</html>", inclusiveBounds: false)
    }

    static func rawHTML(_ resource: StaticString) -> Node<HTML.BodyContext> {
        let url = Bundle.module.staticURL(forResource: resource, withExtension: "html", subdirectory: "Resources")
        return rawHTML(url: url)
    }

    static func inlineSVG(url: URL) -> Node<HTML.BodyContext> {
        getFileContents(url: url, startMarker: #"<\s*svg\b[^>]*>"#, endMarker: "</svg>", inclusiveBounds: true)
    }

    static func inlineSVG(_ resource: StaticString) -> Node<HTML.BodyContext> {
        let url = Bundle.module.staticURL(forResource: resource, withExtension: "svg", subdirectory: "Resources")
        return inlineSVG(url: url)
    }
}
