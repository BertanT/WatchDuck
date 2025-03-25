/*
 Bundle+StaticURL.swift
 Created on 3/6/25.
 
 Copyright (C) 2025 Mehmet Bertan Tarakcioglu
 
 This file is part of WatchDuck.
 
 WatchDuck is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 WatchDuck is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License along with WatchDuck.
 If not, see <https://www.gnu.org/licenses/>.
*/

import Foundation

extension Bundle {
    func staticURL(forResource resource: StaticString?, withExtension ext: StaticString?, subdirectory: StaticString? = nil, localization: StaticString? = nil) -> URL {
        guard let url = self.url(
            forResource: resource?.description,
            withExtension: ext?.description,
            subdirectory: subdirectory?.description,
            localization: localization?.description
        ) else {
            fatalError(
                """
                Invalid static URL string for bundle resource \"\(String(describing: resource))\" (extension: \"\(String(describing: ext))\",\
                subdirectory: \"\(String(describing: subdirectory))\", localization: \"\(String(describing: localization))\").\
                This is likely a bug. Please report it on \(PackageResources.packageURL)
                """
            )
        }

        return url
    }
}
