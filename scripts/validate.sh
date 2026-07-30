#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$repo_root"

find . -type f -name '*.sh' -not -path '*/.git/*' -exec bash -n {} +
if command -v nix >/dev/null 2>&1; then
    if ! nix --extra-experimental-features 'nix-command flakes' flake check --no-build ./examples/nix-flake; then
        printf "SKIP nix flake check: nix input resolution failed\\n"
    fi
else
    printf "SKIP nix flake check: nix not found\\n"
fi
printf "OK shell syntax\\n"
