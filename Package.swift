// swift-tools-version: 6.0
/*
 Package.swift
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

// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(macOS)
let package = Package(
    name: "WatchDuck",
    platforms: [.macOS(.v12)],
    dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser.git", revision: "1.5.0"),
            .package(url: "https://github.com/jpsim/Yams.git", revision: "5.1.3"),
            .package(url: "https://github.com/JohnSundell/Plot.git", revision: "0.14.0"),
            .package(url: "https://github.com/JohnSundell/ShellOut.git", revision: "2.3.0"),
            .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", revision: "0.58.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "watchduck",
            dependencies: [
                            .product(name: "ArgumentParser", package: "swift-argument-parser"),
                            .product(name: "Yams", package: "Yams"),
                            .product(name: "Plot", package: "plot"),
                            .product(name: "ShellOut", package: "ShellOut")
            ],
            resources: [
                .copy("Resources")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        )
    ]
)
#else
let package = Package(
    name: "WatchDuck",
    platforms: [.macOS(.v12)],
    dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser.git", revision: "1.5.0"),
            .package(url: "https://github.com/jpsim/Yams.git", revision: "5.1.3"),
            .package(url: "https://github.com/JohnSundell/Plot.git", revision: "0.14.0"),
            .package(url: "https://github.com/JohnSundell/ShellOut.git", revision: "2.3.0")
    ],
    targets: [
        .executableTarget(
            name: "watchduck",
            dependencies: [
                            .product(name: "ArgumentParser", package: "swift-argument-parser"),
                            .product(name: "Yams", package: "Yams"),
                            .product(name: "Plot", package: "plot"),
                            .product(name: "ShellOut", package: "ShellOut")
            ],
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
#endif
