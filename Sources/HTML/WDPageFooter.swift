/*
 WDPageFooter.swift
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

struct WDPageFooter: Component {
    let formatter = DateFormatter()
    let copyrightName: String?
    let copyrightURL: URL?
    let contactURL: URL?
    let privacyPolicyURL: URL?

    var body: Component {
        ComponentGroup {
            Paragraph {
                Text("Copyright © \(formatter.string(from: Date())) ")
                if let copyrightName, let copyrightURL {
                    Link(copyrightName, url: copyrightURL)
                } else if let copyrightName {
                    Text(copyrightName)
                }
            }

            Navigation {
                if let contactURL {
                    Link("Contact", url: contactURL)
                }
                if let privacyPolicyURL {
                    Link("Privacy Policy", url: privacyPolicyURL)
                }
            }
            .class("footer-nav")
            Paragraph {
                Text("Powered by ")
                Link("\(PackageResources.name)", url: PackageResources.packageURL)
            }
        }
        .linkTarget(.blank)
    }

    init(copyrightText: String?, copyrightURL: URL?, contactURL: URL?, privacyPolicyURL: URL?) {
        self.formatter.dateFormat = "YYYY"
        self.copyrightName = copyrightText
        self.copyrightURL = copyrightURL
        self.contactURL = contactURL
        self.privacyPolicyURL = privacyPolicyURL
    }
}
