#!/bin/bash

# shellcheck source=/dev/null

declare current_dir && \
    current_dir="$(dirname "${BASH_SOURCE[0]}")" && \
    . "$(readlink -f "${current_dir}/../../utilities/utils.sh")"

# GitHub user/repo value of your set-me-up blueprint (e.g.: nicholasadamou/set-me-up-blueprint).
# Set this value when the installer should additionally obtain your blueprint.
export SMU_BLUEPRINT=${SMU_BLUEPRINT:-"nicholasadamou/set-me-up-blueprint"}

# The set-me-up version to download
export SMU_VERSION=${SMU_VERSION:-"1.0.4"}

bash <(curl --progress-bar -L https://raw.githubusercontent.com/nicholasadamou/set-me-up/master/.dotfiles/tag-smu/modules/install.sh) "$@"
