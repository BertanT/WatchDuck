#!/bin/bash
#################################################################################################################################
# build-release.sh
# Created on 03/27/2025
#
# Copyright (C) 2025 Mehmet Bertan Tarakcioglu
#
# This file is part of WatchDuck.
#
# WatchDuck is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# WatchDuck is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with WatchDuck.
# If not, see <https://www.gnu.org/licenses/>.
#################################################################################################################################

# This script is meant to run on a GitHub macOS Action Runner as part of the Release Workflow!
# It assumes to be part of the workflow and will not fail if it is being run by itself.

# This script cross-compiles WatchDuck as a macOS universal bianry and all Linux Distributions
# that support Swift for both arm46 and x86_64.

# Exit bash script on error
set -e

# Prepare to cross-compile for Linux
swift sdk install https://download.swift.org/swift-6.0-release/static-sdk/swift-6.0-RELEASE/swift-6.0-RELEASE_static-linux-0.0.1.artifactbundle.tar.gz --checksum 7984c2cf175bde52ba6ea1fcbe27fc4a148a6237c41c719209c9288ed3ceb652
swift build --configuration release --swift-sdk aarch64-swift-linux-musl

exit 1

# Build for macOS arm64
swift build --configuration release --arch arm64

# Build for macOS x86_64
swift build --configuration release --arch x86_64

# Create macOS universal binary
mkdir -p .build/macos-universal/release
lipo -create .build/arm64-apple-macosx/release/$EXEC_NAME .build/x86_64-apple-macosx/release/$EXEC_NAME\
    -output .build/macos-universal/release/$EXEC_NAME
cp -r .build/arm64-apple-macosx/release/*.bundle .build/macos-universal/release