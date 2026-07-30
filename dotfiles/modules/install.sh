#!/bin/bash

# GitHub user/repo & branch value of your set-me-up blueprint (e.g.: dotbrains/set-me-up-blueprint/master).
# Set this value when the installer should additionally obtain your blueprint.
export SMU_BLUEPRINT=${SMU_BLUEPRINT:-"dotbrains/set-me-up-blueprint"}
export SMU_BLUEPRINT_BRANCH=${SMU_BLUEPRINT_BRANCH:-"master"}

# A set of ignored paths that 'git' will ignore
# syntax: '<path>|<path>'
# Note: <path> is relative to '$HOME/set-me-up'
export SMU_IGNORED_PATHS="${SMU_IGNORED_PATHS:-""}"

export SMU_INSTALLER_REF="${SMU_INSTALLER_REF:-main}"
export SMU_INSTALLER_URL="${SMU_INSTALLER_URL:-https://raw.githubusercontent.com/dotbrains/set-me-up-installer/${SMU_INSTALLER_REF}/install.sh}"

bash <(curl -s -L "$SMU_INSTALLER_URL") "$@"
