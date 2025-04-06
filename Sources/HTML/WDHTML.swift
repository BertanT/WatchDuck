/*
 WDHTML.swift
 Created on 7/30/24.
 
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

struct WDHTML {
    let config: WDConfig
    let log: WDLog

    private func generateHTML() -> String {
        let html = HTML(
            .lang(.english),
            .head(
                // Configure meta tags
                .meta(.charset(.utf8)),
                .meta(.name("viewport"), .content("width=device-width, initial-scale=1.0")),
                .meta(.attribute(named: "http-equiv", value: "X-UA-Compatible"), .content("ie=edge")),
                .meta(.name("format-detection"), .content("telephone=no")),

                // Set up external sources
                .stylesheet("./styles/wdstyle.css"),
                .script(.src("./scripts/wdtime.js")),

                .favicon("./images/wdfavicon.png"),

                // Set up webpage title and other SEO related tags
                .title(config.metaTitle ?? config.navHeaderTitle),
                .meta(.name("description"), .content(config.metaDescription ?? config.metaTitle ?? config.navHeaderTitle)),
                .meta(.name("keywords"), .content(config.metaKeywords?.joined(separator: ", ") ?? "")),
                .meta(.name("author"), .content(config.metaAuthor)),
                .meta(.name("copyright"), .content(config.metaCopyright ?? config.metaAuthor)),
                .meta(.name("language"), .content(config.metaLanguage)),
                .meta(.name("robots"), .content(config.metaRobots))
            ),

            .body(
                .header(
                    .component(WDPageHeader(siteTitle: config.navHeaderTitle, supportURL: config.supportURL))
                ),

                .main(
                    .component(WDPageStatusList(logs: log.statusList)),
                    .component(WDPageListSubtext(lastUpdate: log.lastUpdate))
                ),

                .footer(
                    .component(WDPageFooter(copyrightText: config.copyrightName, copyrightURL: config.copyrightURL, contactURL: config.contactURL, privacyPolicyURL: config.privacyPolicyURL))
                )
            )
        )
        return html.render()
    }

    private func copyDefaultAssets() throws {
        let htmlDirs: [String: [String]] = [
            "styles": ["css"],
            "images": ["png", "svg", "jpg", "jpeg", "gif", "webp", "ico"],
            "fonts": ["woff", "woff2", "ttf", "otf"],
            "scripts": ["js"]
        ]

        let assetFiles = Bundle.module.staticURLs(forResourcesWithExtension: nil, subdirectory: "Resources/DefaultHTMLAssets")

        for (dir, extensions) in htmlDirs {
            let filteredFiles = assetFiles.filter { extensions.contains(($0.pathExtension).lowercased()) }

            if filteredFiles.isEmpty {
                continue
            }

            let destRoot = config.HTMLOutputDirectory.appendingPathComponent(dir)
            try FileManager.default.createDirectory(at: destRoot, withIntermediateDirectories: true)

            for file in filteredFiles {
                let destFile = destRoot.appendingPathComponent(file.lastPathComponent)
                if FileManager.default.fileExists(atPath: destFile.path) {
                    continue
                }

                try FileManager.default.copyItem(at: file as URL, to: destFile)
            }
        }
    }

    func saveHTMLFile() throws {
        try FileManager.default.createDirectory(at: config.HTMLOutputDirectory, withIntermediateDirectories: true)

        if config.tryDefaultAssets {
            try copyDefaultAssets()
        }

        let htmlPath = config.HTMLOutputDirectory.appendingPathComponent("index.html")
        try generateHTML().write(to: htmlPath, atomically: true, encoding: .utf8)
    }
}
