#!/bin/bash
#################################################################################################################################
# pack-builds.sh
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

# This script takes all the binaries compiled by the build-release.sh script and packages them into tarballs,
# ready for release and distribution!

# Exit bash script on error
set -e

# Create a directory to store the tarballs
mkdir .build/tarballs

# Package macOS universal binary
cd .build/macos-universal/release
tar -czf ../../../.build/tarballs/watchduck-$NEW_TAG-macos-universal.tar.gz .
cd -
