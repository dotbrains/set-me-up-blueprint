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
