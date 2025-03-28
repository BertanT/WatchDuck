#!/bin/bash
#################################################################################################################################
# update-changelog.sh
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

# This script updtaes the changelog for the new release, replacing the 'Unreleased' section with the new tag
# and linking to the corresponding comparison URL on GitHub.

# WARNING: For this to work, the changelog must follow the Keep a Changelog format with an 'Unreleased' section!

# Exit bash script on error
set -e

# Check if any tags exist
if git tag -l | grep -q .; then
    # Get prevoius tag if it exists
    PREV_TAG=$(git describe --abbrev=0 --tags HEAD^)
    
    # Create a URL to link to the new tag title in the changelog
    compare_url="https://github.com/$REPO/compare/$PREV_TAG...$NEW_TAG"
    
    # Create the new markdown tag title with the correct comparison link
    released_tag="[$NEW_TAG]: $compare_url"

else
    # If this is the first tag, link to the release URL instead
    release_url="https://github.com/REPO/tag/$NEW_TAG"
    released_tag="[$NEW_TAG]: $release_url"
fi

# Replace 'Unreleased' with the new tag and add a date
sed -i '' "s/## \[Unreleased\]/## [$NEW_TAG] - $(date +'%Y-%m-%d')/g" CHANGELOG.md
          
# Add a new 'Unreleased' section
sed -i '' "0,/## \[/s//## [Unreleased]\n\n## [/" CHANGELOG.md

# Replace the 'Unreleased' link to compare with the new tag
sed -i '' "s|\[unreleased\]: .*|[unreleased]: https://github.com/$REPO/compare/$NEW_TAG...HEAD|I" CHANGELOG.md

# Only add a comparison link if this isn't the first tag
echo -e "\n$released_tag" >> CHANGELOG.md