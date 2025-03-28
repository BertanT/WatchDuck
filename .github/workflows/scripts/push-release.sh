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

# Just before creating a new release, this script will push the changes to the changelog to the repo.
# It wil then create the new tag and also push it.

# Commit and push the updated changelog
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add CHANGELOG.md 
git commit -m "Update changelog for release $NEW_TAG"
git push origin HEAD:$TARGET_BRANCH

# Create and push the new tag
git tag $NEW_TAG
git push origin $NEW_TAG