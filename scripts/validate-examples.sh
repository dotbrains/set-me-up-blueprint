#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

python3 - "$repo_root" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
errors = []


def parse_simple_toml(path):
    current = None
    data = {}
    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("[") and line.endswith("]"):
            current = line.strip("[]")
            data.setdefault(current, {})
            continue
        if "=" not in line or current != "provisioning":
            continue
        key, value = line.split("=", 1)
        data[current][key.strip()] = value.strip().strip('"')
    return data


for path in sorted(root.glob("**/smu.toml")) + sorted(root.glob("profiles/*.toml")):
    if ".git" in path.parts:
        continue
    provisioning = parse_simple_toml(path).get("provisioning", {})
    mode = provisioning.get("mode")
    adapter = provisioning.get("adapter")
    nix_adapter = provisioning.get("nix_adapter")
    rel = path.relative_to(root)
    if mode not in {"rcm", "nix", "hybrid"}:
        errors.append(f"{rel}: unsupported or missing provisioning.mode")
    if mode == "rcm" and adapter != "rcm":
        errors.append(f"{rel}: rcm mode requires adapter rcm")
    if mode == "nix" and adapter not in {"home-manager", "nix-darwin", "nixos"}:
        errors.append(f"{rel}: nix mode requires a Nix-family adapter")
    if mode == "hybrid" and adapter != "hybrid":
        errors.append(f"{rel}: hybrid mode requires adapter hybrid")
    if mode == "hybrid" and nix_adapter not in {"home-manager", "nix-darwin", "nixos"}:
        errors.append(f"{rel}: hybrid mode requires a Nix-family nix_adapter")

for workflow in ("rcm.yml", "nix.yml", "hybrid.yml"):
    path = root / "examples" / "github-actions" / workflow
    if not path.exists():
        errors.append(f"examples/github-actions/{workflow}: missing")

for provider in ("debian-vps", "ubuntu-vps", "arch-vps", "nixos-vps", "digitalocean-droplet", "hetzner-cloud"):
    path = root / "examples" / "providers" / provider / "smu.toml"
    if not path.exists():
        errors.append(f"examples/providers/{provider}/smu.toml: missing")

if errors:
    for error in errors:
        print(f"FAIL {error}")
    sys.exit(1)
print("OK blueprint examples")
PY
