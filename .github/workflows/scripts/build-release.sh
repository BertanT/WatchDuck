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

# Build for macOS arm64
swift build --configuration release --arch arm64

# Build for macOS x86_64
swift build --configuration release --arch x86_64

# Create macOS universal binary
mkdir -p .build/macos-universal/release
lipo -create .build/arm64-apple-macosx/release/watchduck .build/x86_64-apple-macosx/release/watchduck\
    -output .build/macos-universal/release/watchduck
cp .build/arm64-apple-macosx/release/*.bundle .build/macos-universal/release
