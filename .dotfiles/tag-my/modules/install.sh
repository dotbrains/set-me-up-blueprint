#!/bin/bash

# GitHub user/repo & branch value of your set-me-up blueprint (e.g.: nicholasadamou/set-me-up-blueprint/master).
# Set this value when the installer should additionally obtain your blueprint.
export SMU_BLUEPRINT=${SMU_BLUEPRINT:-"nicholasadamou/set-me-up-blueprint"}
export SMU_BLUEPRINT_BRANCH=${SMU_BLUEPRINT_BRANCH:-"master"}

# The set-me-up version to download
export SMU_VERSION=${SMU_VERSION:-"master"}

bash <(curl --progress-bar -L https://raw.githubusercontent.com/nicholasadamou/set-me-up/master/.dotfiles/tag-smu/modules/install.sh) "$@"
