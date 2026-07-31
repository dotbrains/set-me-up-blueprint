# Provisioning Compatibility

This blueprint supports three provisioning modes:

| Mode | Primary adapter | CI example | Migration role |
| --- | --- | --- | --- |
| `rcm` | `rcm` | `examples/github-actions/rcm.yml` | Existing thoughtbot `rcm` dotfile flow |
| `nix` | `home-manager`, `nix-darwin`, or `nixos` | `examples/github-actions/nix.yml` | Final Nix-first state |
| `hybrid` | `hybrid` with `nix_adapter` | `examples/github-actions/hybrid.yml` | Transition state with `rcm` fallback |

Provider examples:

| Provider example | Target | Mode | Adapter | Hybrid Nix adapter |
| --- | --- | --- | --- | --- |
| `examples/providers/debian-vps` | Debian VPS | `nix` | `home-manager` | - |
| `examples/providers/ubuntu-vps` | Ubuntu VPS | `nix` | `home-manager` | - |
| `examples/providers/arch-vps` | Arch VPS | `nix` | `home-manager` | - |
| `examples/providers/nixos-vps` | NixOS VPS | `nix` | `nixos` | - |
| `examples/providers/digitalocean-droplet` | DigitalOcean Droplet | `hybrid` | `hybrid` | `home-manager` |
| `examples/providers/hetzner-cloud` | Hetzner Cloud | `hybrid` | `hybrid` | `home-manager` |

Use `smu blueprint ci --path . --check-docs --json` in blueprint CI. The local
`scripts/blueprint-ci-contract.sh --check-docs` script is kept as a fallback
for template forks that have not updated the installer yet. Both checks cover
mode/adapter consistency, provider examples, copyable GitHub Actions examples,
and this readiness document.

Use `smu blueprint providers --path . --json` to print this provider support
matrix for tools or docs generators.
Use `smu provisioning-adapter capabilities --json` to print the adapter
capability contract that explains each adapter's mode, engine, host families,
Nix requirement, scope, fallback behavior, and adapter authoring contract.
The checked-in `examples/providers/provider-matrix.json` mirrors that contract
for template validation so provider examples and adapter host-family support do
not drift.
Use `smu blueprint recommend --target ubuntu --path . --json` to turn a host
intent into a recommended mode, adapter, and provider example.
Add `--dry-run` to preview the generated starter config, or `--write --output
smu.toml` to create it.
Use `--validate` to prove an existing starter config still matches the selected
target recommendation.
Use `smu provisioning-adapter preflight --adapter home-manager --profile
default --json` before apply to inspect module coverage, generated artifact
paths, hybrid fallback decisions, and intended commands without mutating the
host.
The GitHub Actions examples include a preflight step so CI templates fail when
that read-only gate is missing from a blueprint workflow.
Machine-readable readiness payloads include `readiness.preflight` and
`readiness.summary.workflow_preflight`, which agents and release tooling can
use to prove a blueprint is still validating preflight coverage before apply.
