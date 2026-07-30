# VPS Provider Examples

These examples show the supported blueprint shapes for headless hosts. Copy the
matching `smu.toml` into a fork, then adjust modules for the host role.

| Example | Host shape | Provisioning mode |
| --- | --- | --- |
| `debian-vps` | Debian VPS | `nix` with Home Manager |
| `ubuntu-vps` | Ubuntu VPS | `nix` with Home Manager |
| `arch-vps` | Arch VPS | `nix` with Home Manager |
| `nixos-vps` | NixOS VPS | `nix` with NixOS |
| `digitalocean-droplet` | DigitalOcean Debian/Ubuntu droplet | `hybrid` |
| `hetzner-cloud` | Hetzner Debian/Ubuntu cloud host | `hybrid` |
