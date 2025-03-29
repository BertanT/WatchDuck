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

# This script combines macOS build binaries and generates a singel universal binary in its own build directory.

# Exit bash script on error
set -e

# Create a new directory to contain the universal binary build
mkdir -p .build/macos-universal/release

# Create universal binary
lipo -create .build/arm64-apple-macosx/release/$EXEC_NAME .build/x86_64-apple-macosx/release/$EXEC_NAME\
    -output .build/macos-universal/release/$EXEC_NAME

# Copy the universal binary and its bundle to its new home!
cp -r .build/arm64-apple-macosx/release/*.bundle .build/macos-universal/release