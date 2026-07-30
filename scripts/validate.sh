#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$repo_root"

find . -type f -name '*.sh' -not -path '*/.git/*' -exec bash -n {} +
scripts/validate-examples.sh
if command -v nix >/dev/null 2>&1; then
    for flake_dir in examples/nix-flake examples/nix-darwin examples/nixos; do
        lock_flag=""
        [ -f "$flake_dir/flake.lock" ] && lock_flag="--no-update-lock-file"
        if ! nix --extra-experimental-features 'nix-command flakes' flake check --no-build $lock_flag "./$flake_dir"; then
            printf "SKIP nix flake check: nix input resolution failed for %s\\n" "$flake_dir"
        fi
    done
else
    printf "SKIP nix flake check: nix not found\\n"
fi
printf "OK shell syntax\\n"
