# Provisioning Compatibility

This blueprint supports three provisioning modes:

| Mode | Primary adapter | CI example | Migration role |
| --- | --- | --- | --- |
| `rcm` | `rcm` | `examples/github-actions/rcm.yml` | Existing thoughtbot `rcm` dotfile flow |
| `nix` | `home-manager`, `nix-darwin`, or `nixos` | `examples/github-actions/nix.yml` | Final Nix-first state |
| `hybrid` | `hybrid` with `nix_adapter` | `examples/github-actions/hybrid.yml` | Transition state with `rcm` fallback |

Provider examples:

| Provider example | Mode | Adapter |
| --- | --- | --- |
| `examples/providers/debian-vps` | `nix` | `home-manager` |
| `examples/providers/ubuntu-vps` | `nix` | `home-manager` |
| `examples/providers/arch-vps` | `nix` | `home-manager` |
| `examples/providers/nixos-vps` | `nix` | `nixos` |
| `examples/providers/digitalocean-droplet` | `hybrid` | `hybrid` |
| `examples/providers/hetzner-cloud` | `hybrid` | `hybrid` |

Use `smu blueprint ci --path . --check-docs --json` in blueprint CI. The local
`scripts/blueprint-ci-contract.sh --check-docs` script is kept as a fallback
for template forks that have not updated the installer yet. Both checks cover
mode/adapter consistency, provider examples, copyable GitHub Actions examples,
and this readiness document.
