#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
json_output=false

if [ "${1:-}" = "--json" ]; then
    json_output=true
fi

cd "$repo_root"

python3 - "$repo_root" "$json_output" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
json_output = sys.argv[2] == "true"
errors = []
checks = []
provider_examples = {
    "debian-vps": {"mode": "nix", "adapter": "home-manager", "nix_adapter": None},
    "ubuntu-vps": {"mode": "nix", "adapter": "home-manager", "nix_adapter": None},
    "arch-vps": {"mode": "nix", "adapter": "home-manager", "nix_adapter": None},
    "nixos-vps": {"mode": "nix", "adapter": "nixos", "nix_adapter": None},
    "digitalocean-droplet": {"mode": "hybrid", "adapter": "hybrid", "nix_adapter": "home-manager"},
    "hetzner-cloud": {"mode": "hybrid", "adapter": "hybrid", "nix_adapter": "home-manager"},
}
adapter_capabilities = {
    "rcm": {"mode": "rcm", "engine": "rcm", "requires_nix": False, "supports_fallback": False, "scope": "user"},
    "home-manager": {"mode": "nix", "engine": "home-manager", "requires_nix": True, "supports_fallback": False, "scope": "user"},
    "nix-darwin": {"mode": "nix", "engine": "nix-darwin", "requires_nix": True, "supports_fallback": False, "scope": "system"},
    "nixos": {"mode": "nix", "engine": "nixos", "requires_nix": True, "supports_fallback": False, "scope": "system"},
    "hybrid": {"mode": "hybrid", "engine": "home-manager", "requires_nix": True, "supports_fallback": True, "scope": "user"},
}


def record(name, path, ok, message):
    checks.append({
        "name": name,
        "path": str(path),
        "ok": ok,
        "message": message,
    })
    if not ok:
        errors.append(f"{path}: {message}")


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
    before = len(errors)
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
    checks.append({
        "name": "mode-adapter",
        "path": str(rel),
        "ok": len(errors) == before,
        "message": f"{mode or '<missing>'}/{adapter or '<missing>'}",
    })

for workflow in ("rcm.yml", "nix.yml", "hybrid.yml"):
    path = root / "examples" / "github-actions" / workflow
    rel = path.relative_to(root)
    record("github-actions-example", rel, path.exists(), "present" if path.exists() else "missing")

for provider, expected in provider_examples.items():
    path = root / "examples" / "providers" / provider / "smu.toml"
    rel = path.relative_to(root)
    if not path.exists():
        record("provider-example", rel, False, "missing")
        continue
    provisioning = parse_simple_toml(path).get("provisioning", {})
    mode = provisioning.get("mode")
    adapter = provisioning.get("adapter")
    nix_adapter = provisioning.get("nix_adapter")
    ok = mode == expected["mode"] and adapter == expected["adapter"]
    if expected["nix_adapter"]:
        ok = ok and nix_adapter == expected["nix_adapter"]
    else:
        ok = ok and not nix_adapter
    record(
        "provider-example",
        rel,
        ok,
        f"{mode or '<missing>'}/{adapter or '<missing>'}",
    )
    checks[-1]["capability"] = adapter_capabilities.get(adapter, {})

payload = {"valid": not errors, "errors": errors, "checks": checks}
if json_output:
    print(json.dumps(payload, indent=2, sort_keys=True))
    sys.exit(0 if not errors else 1)
if errors:
    for error in errors:
        print(f"FAIL {error}")
    sys.exit(1)
print("OK blueprint examples")
PY
