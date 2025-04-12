// swift-tools-version: 6.0.3
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

// This is quite janky, but it's more streamlined than redefining the manifest for each platform
// We are using the prebuilt binary for SwiftLint, which is not statically linked and is not portable across
// different Linux distributions than the ones used in their Docker image. Since WatchDuck is designed to be a
// portable binary, SwiftLint is simply omitted from Linux builds. This is okay since the WatchDuck CI always
// runs on a macOS machine, and the Linux binaries are cross-compiled statically. We could build SwiftLint from
// source as part of the WatchDuck build process, but that would add too much overhead and get annoying pretty quickly. :}
func platformDependencies() -> [Package.Dependency] {
    #if os(macOS)
    return [Package.Dependency.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", revision: "a60b5704f335fc18aa3aea3564c74774a338425f")]
    #else
    return []
    #endif
}

func platformPlugins() -> [Target.PluginUsage] {
    #if os(macOS)
    return [Target.PluginUsage.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
    #else
    return []
    #endif
}

let package = Package(
    name: "WatchDuck",
    platforms: [.macOS(.v12)],
    dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser.git", revision: "41982a3656a71c768319979febd796c6fd111d5c"),
            .package(url: "https://github.com/jpsim/Yams.git", revision: "b4b8042411dc7bbb696300a34a4bf3ba1b7ad19b"),
            .package(url: "https://github.com/JohnSundell/Plot.git", revision: "271926b4413fe868739d99f5eadcf2bd6cd62fb8"),
            .package(url: "https://github.com/JohnSundell/ShellOut.git", revision: "e1577acf2b6e90086d01a6d5e2b8efdaae033568"),
            .package(url: "https://github.com/swiftlang/swift-docc-plugin", revision: "85e4bb4e1cd62cec64a4b8e769dcefdf0c5b9d64")
    ] + platformDependencies(),
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "watchduck",
            dependencies: [
                            .product(name: "ArgumentParser", package: "swift-argument-parser"),
                            .product(name: "Yams", package: "Yams"),
                            .product(name: "Plot", package: "plot"),
                            .product(name: "ShellOut", package: "ShellOut"),
            ],
            resources: [
                .copy("Resources")
            ],
            plugins: [] + platformPlugins()
        )
    ]
)
