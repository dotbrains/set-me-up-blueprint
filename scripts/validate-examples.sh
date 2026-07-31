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
summary = {
    "configs": 0,
    "provider_examples": 0,
    "workflow_examples": 0,
    "workflow_preflight": 0,
}
provider_matrix_path = root / "examples" / "providers" / "provider-matrix.json"
provider_matrix = json.loads(provider_matrix_path.read_text())
provider_examples = provider_matrix["providers"]
adapter_capabilities = provider_matrix["adapters"]
authoring_contract = provider_matrix.get("contract", {})
expected_authoring_contract = {
    "version": 1,
    "blueprint_keys": [
        "provisioning.mode",
        "provisioning.adapter",
        "provisioning.nix_adapter",
    ],
    "module_manifest_table": "adapters",
    "module_adapter_required_keys": ["path"],
    "preflight_command": "smu provisioning-adapter preflight --adapter <adapter> --profile <profile> --json",
    "ci_command": "smu blueprint ci --path <blueprint> --check-docs --json",
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


record(
    "adapter-authoring-contract",
    provider_matrix_path.relative_to(root),
    authoring_contract == expected_authoring_contract,
    "version 1" if authoring_contract == expected_authoring_contract else "missing or stale",
)

for path in sorted(root.glob("**/smu.toml")) + sorted(root.glob("profiles/*.toml")):
    if ".git" in path.parts:
        continue
    summary["configs"] += 1
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
    if adapter in adapter_capabilities and mode != adapter_capabilities[adapter]["mode"]:
        errors.append(f"{rel}: adapter {adapter} does not support mode {mode}")
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
    if path.exists():
        summary["workflow_examples"] += 1
        workflow_text = path.read_text()
        has_preflight = "provisioning-adapter preflight" in workflow_text
        if has_preflight:
            summary["workflow_preflight"] += 1
        record(
            "github-actions-preflight",
            rel,
            has_preflight,
            "preflight" if has_preflight else "missing preflight",
        )

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
    if ok:
        summary["provider_examples"] += 1
    checks[-1]["capability"] = adapter_capabilities.get(adapter, {})
    host_family = expected.get("host_family")
    host_ok = bool(adapter and host_family in adapter_capabilities.get(adapter, {}).get("host_families", []))
    if mode == "hybrid" and nix_adapter:
        host_ok = host_ok and host_family in adapter_capabilities.get(nix_adapter, {}).get("host_families", [])
    record(
        "provider-host-family",
        rel,
        host_ok,
        host_family or "<missing>",
    )

payload = {
    "contract": authoring_contract,
    "valid": not errors,
    "errors": errors,
    "readiness": {
        "preflight": "passed" if not errors else "failed",
        "summary": summary,
    },
    "checks": checks,
}
if json_output:
    print(json.dumps(payload, indent=2, sort_keys=True))
    sys.exit(0 if not errors else 1)
if errors:
    for error in errors:
        print(f"FAIL {error}")
    sys.exit(1)
print("OK blueprint examples")
PY
