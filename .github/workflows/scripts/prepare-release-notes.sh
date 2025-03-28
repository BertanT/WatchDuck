#!/bin/bash
#################################################################################################################################
# prep-release-notes.sh
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

# This script prepares relese notes by extracting them from the changelog and obtaining tarball checksums.

# Exit bash script on error
set -e

# Extract relese notes from the changelog and put them into RELEASE_NOTES.md
awk "/## \[$NEW_TAG\]/{flag=1;next} /## \[/&&flag{flag=0} flag" CHANGELOG.md | sed '/^\[.*\]: /d' > RELEASE_NOTES.md

# Extract tarball checksums and append them into RELEASE_NOTES.md
echo -e "\n## SHA256 Checksums" >> RELEASE_NOTES.md
for file in .build/tarballs/*.sha256; do
    filename=$(basename "${file%.sha256}")
    checksum=$(cat "$file")
    echo "**$filename**: $checksum" >> RELEASE_NOTES.md
done