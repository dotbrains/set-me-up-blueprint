#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
json_output=false
check_docs=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        --json)
            json_output=true
            ;;
        --check-docs)
            check_docs=true
            ;;
        *)
            printf "Usage: %s [--json] [--check-docs]\\n" "$0" >&2
            exit 2
            ;;
    esac
    shift
done

cd "$repo_root"

examples_json="$(scripts/validate-examples.sh --json)"
docs_ok=true
docs_message="not checked"
docs_path="PROVISIONING-COMPATIBILITY.md"
contracts_ok=true
contracts_message="validated"
contracts=(
    plan
    secrets-doctor
    trust-doctor
    support-bundle
    conformance
)

for contract in "${contracts[@]}"; do
    if ! python3 set-me-up-installer/smu.py contract validate "$contract" --json >/dev/null; then
        contracts_ok=false
        contracts_message="failed: $contract"
        break
    fi
done

if "$check_docs"; then
    if [ -f "$docs_path" ] &&
        grep -q 'examples/providers/debian-vps' "$docs_path" &&
        grep -q 'examples/github-actions/nix.yml' "$docs_path"; then
        docs_message="present"
    else
        docs_ok=false
        docs_message="missing or stale"
    fi
fi

if "$json_output"; then
    python3 - "$examples_json" "$docs_ok" "$docs_message" "$docs_path" "$contracts_ok" "$contracts_message" <<'PY'
import json
import sys

examples = json.loads(sys.argv[1])
docs_ok = sys.argv[2] == "true"
payload = {
    "valid": examples["valid"] and docs_ok and sys.argv[5] == "true",
    "examples": examples,
    "docs": {
        "path": sys.argv[4],
        "ok": docs_ok,
        "message": sys.argv[3],
    },
    "contracts": {
        "ok": sys.argv[5] == "true",
        "message": sys.argv[6],
    },
}
print(json.dumps(payload, indent=2, sort_keys=True))
sys.exit(0 if payload["valid"] else 1)
PY
    exit $?
fi

scripts/validate-examples.sh
if ! "$contracts_ok"; then
    printf "FAIL contracts: %s\\n" "$contracts_message" >&2
    exit 1
fi
if ! "$docs_ok"; then
    printf "FAIL %s: %s\\n" "$docs_path" "$docs_message" >&2
    exit 1
fi
printf "OK blueprint CI contract\\n"
