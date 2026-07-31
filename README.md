# `set-me-up` blueprint

[![License: PolyForm Shield 1.0.0](https://img.shields.io/badge/License-PolyForm%20Shield%201.0.0-blue.svg)](https://polyformproject.org/licenses/shield/1.0.0)

A template to manage your personal `set-me-up` setup. A blueprint is the
repository users install; `smu` and the shared module repositories provide the
reusable installer behavior.

## What's inside

1.  A `rcm` tag called [example](../dotfiles/tag-example) and an adapted `rcrc` file.
2.  [Your own module](../dotfiles/modules/example) called `example`. You can go crazy with your customizations here.
3.  [Installer](../dotfiles/modules/install.sh) that is required to download `set-me-up` on top of your blueprint.
4.  [`smu.toml`](../smu.toml), which selects the provisioning adapter and
    default profile modules for this blueprint.

## How to use

1.  [Read the docs](https://github.com/dotbrains/set-me-up-docs).
2.  Fork this repository.
3.  Add your customizations inside the [tag-example](../dotfiles/tag-example).
4.  Change the [`SMU_BLUEPRINT` variable value](../dotfiles/modules/install.sh#L5) to your GitHub `user\repo` combination.
5.  Keep `adapter = "rcm"` in [`smu.toml`](../smu.toml) for the traditional
    thoughtbot `rcm` dotfile flow, or change it to `home-manager` for a
    Nix/Home Manager blueprint.

6.  Use the [installer](../dotfiles/modules/install.sh) to obtain your
    blueprint setup by changing the following within the below snippet:

    1.  **_YOUR-USERNAME_** - This should be changed to your `GitHub` username.

    2.  **_BRANCH-NAME-HERE_** - This should be changed based on the host device's kernel.

    ```bash
    bash <(curl -s -L https://raw.githubusercontent.com/<YOUR-USERNAME>/set-me-up-blueprint/<BRANCH-NAME-HERE>/dotfiles/modules/install.sh)
    ```

## Install and update flow

The bootstrap script is intentionally small:

1.  It exports `SMU_BLUEPRINT=<owner>/<repo>` and
    `SMU_BLUEPRINT_BRANCH=<branch>`.
2.  It delegates to
    `https://raw.githubusercontent.com/dotbrains/set-me-up-installer/main/install.sh`.
3.  The installer clones this blueprint into `${SMU_HOME_DIR:-$HOME/set-me-up}`.
4.  On later runs, the installer updates the blueprint with a fast-forward
    merge and refuses to continue when local changes are present.

Preview a bootstrap before it changes the checkout:

```bash
INSTALL_URL="https://raw.githubusercontent.com/<YOUR-USERNAME>/set-me-up-blueprint/<BRANCH-NAME-HERE>/dotfiles/modules/install.sh"
bash <(curl -s -L "$INSTALL_URL") --plan
bash <(curl -s -L "$INSTALL_URL") --plan --json
bash <(curl -s -L "$INSTALL_URL") --doctor --json
```

Test an installer candidate branch before it is published to `main`:

```bash
SMU_INSTALLER_REF=my-branch bash <(curl -s -L "$INSTALL_URL") --plan
```

Routine updates should use `smu` from the installed checkout:

```bash
smu update blueprint   # update your blueprint repository
smu update installer   # update the smu installer repository
smu update modules     # update blueprint submodules
smu update --all       # update blueprint, installer, modules, and generated config
```

## Provisioning adapters

Blueprints choose their primary provisioning engine in `smu.toml`:

```toml
[provisioning]
mode = "rcm"
adapter = "rcm"

[profile.default]
modules = ["example"]
```

Use `rcm` for shell/Brewfile/packages modules and thoughtbot `rcm` dotfile
symlinks. Use `home-manager` when modules publish a Home Manager implementation
in `module.toml`; `smu provisioning-adapter apply --adapter home-manager
--profile default` writes the generated Home Manager import file and runs
`home-manager switch`.

Profile examples live in [`profiles/`](profiles/):

- [`desktop-rcm.toml`](profiles/desktop-rcm.toml): thoughtbot `rcm` first.
- [`desktop-home-manager.toml`](profiles/desktop-home-manager.toml): user-level
  Home Manager on macOS, Debian/Ubuntu, or Arch with Nix installed.
- [`hybrid.toml`](profiles/hybrid.toml): Home Manager first with `rcm` fallback.
- [`vps-home-manager.toml`](profiles/vps-home-manager.toml): headless VPS shape.
- [`nixos-server.toml`](profiles/nixos-server.toml): full NixOS host shape.

The example directories show Nix-first blueprint shapes:

- [`examples/nix-flake`](examples/nix-flake): Home Manager user provisioning.
- [`examples/nix-darwin`](examples/nix-darwin): macOS system provisioning.
- [`examples/nixos`](examples/nixos): NixOS host provisioning.
- [`examples/providers`](examples/providers): Debian, Ubuntu, Arch, NixOS,
  DigitalOcean, and Hetzner VPS shapes.
- [`examples/github-actions`](examples/github-actions): copyable validation
  jobs for `rcm`, Nix, and hybrid blueprints.

Inspect the supported provider shapes before choosing a blueprint mode:

```bash
smu blueprint providers --path . --json
smu blueprint recommend --target ubuntu --path . --json
smu blueprint recommend --target ubuntu --path . --dry-run
smu blueprint recommend --target ubuntu --path . --write --output smu.toml
smu blueprint recommend --target ubuntu --path . --validate --json
smu provisioning-adapter capabilities --json
smu provisioning-adapter preflight --adapter home-manager --profile default --json
```

The current provider matrix is:

| Provider example | Target | Mode | Adapter | Hybrid Nix adapter |
| --- | --- | --- | --- | --- |
| [`debian-vps`](examples/providers/debian-vps) | Debian VPS | `nix` | `home-manager` | - |
| [`ubuntu-vps`](examples/providers/ubuntu-vps) | Ubuntu VPS | `nix` | `home-manager` | - |
| [`arch-vps`](examples/providers/arch-vps) | Arch VPS | `nix` | `home-manager` | - |
| [`nixos-vps`](examples/providers/nixos-vps) | NixOS VPS | `nix` | `nixos` | - |
| [`digitalocean-droplet`](examples/providers/digitalocean-droplet) | DigitalOcean Droplet | `hybrid` | `hybrid` | `home-manager` |
| [`hetzner-cloud`](examples/providers/hetzner-cloud) | Hetzner Cloud | `hybrid` | `hybrid` | `home-manager` |

Use the capability output when tooling needs to decide between adapters. It
records each adapter's mode, engine, scope, supported host families, Nix
requirement, and fallback behavior.
The checked-in [`provider-matrix.json`](examples/providers/provider-matrix.json)
is the contract used by example validation for provider targets and adapter
host-family support.
Use the recommendation command when starting from a host intent. Supported
targets include `debian`, `ubuntu`, `arch`, `nixos`, `digitalocean`, `hetzner`,
`macos`, and `rcm-only`.
Add `--dry-run` to preview the generated starter `smu.toml`; add `--write
--output smu.toml` to create it in a fork.
Use `--validate` to check an existing starter config against the recommendation
for that target.
Run `smu provisioning-adapter preflight --adapter <adapter> --profile default
--json` after validation to inspect module coverage, generated artifact paths,
hybrid fallback decisions, and the apply command before anything mutates the
host.

When an example has `flake.lock`, validation runs `nix flake check` in locked
mode with `--no-update-lock-file`. Without a lockfile, validation still checks
the flake shape when Nix can resolve inputs.

Profiles may override the global adapter:

```toml
[provisioning]
adapter = "rcm"

[profile.default]
adapter = "home-manager"
modules = ["base", "nushell"]
```

Use `smu nix init --profile default` to generate the Home Manager import and
flake files, `smu nix switch --profile default` to apply them, and
`smu nix parity --profile default --json` to compare remaining `rcm` coverage
against the Nix path.

Use `smu blueprint init --mode rcm|nix|hybrid` when starting a fork from an
empty checkout. The generated `smu.toml` records both the user-facing
`mode` and the concrete adapter that `smu` should apply.

Validate that mode choice before applying modules:

```bash
smu blueprint doctor --strict --json
```

For an existing `rcm` fork, migrate in stages:

1. Run `smu blueprint migrate --from rcm --to hybrid --force --json` to keep
   `rcm` fallback while adding Nix coverage.
2. Run `smu nix migrate compare --profile default --json` to classify modules
   as `ported`, `partial`, `blocked`, or `kept-rcm`.
3. Move to `smu blueprint migrate --from rcm --to nix --force --json` once
   every required module has a Nix adapter.

Blueprint examples are checked by `scripts/validate-examples.sh`, which
validates mode/adapter consistency, provider examples, and copyable GitHub
Actions workflows without requiring a live installed checkout.

Use this contract in CI:

```bash
smu blueprint ci --path . --check-docs --json
scripts/blueprint-ci-contract.sh --check-docs
scripts/blueprint-ci-contract.sh --check-docs --json
```

The `smu blueprint ci` command is the stable installer-owned CI entrypoint.
The local script is kept as a template fallback. Both wrap example validation
and check the checked-in provisioning readiness matrix at
[`PROVISIONING-COMPATIBILITY.md`](PROVISIONING-COMPATIBILITY.md).
Use `smu blueprint migrate ...` locally when changing modes; use the CI
contract to prove a committed blueprint remains internally consistent.

If you intentionally want to discard local blueprint changes during bootstrap
or update, pass `--force-reset`.

## Headless VPS

For an Ubuntu/Debian VPS such as a DigitalOcean Droplet, install from your
blueprint fork, then provision the targeted server module:

```bash
SMU_SUBMODULE_SCOPE=platform bash <(curl -s -L "$INSTALL_URL")
smu --setup-profile vps
```

Use this path for SSH-only hosts. It avoids the workstation-oriented Debian
modules and installs only a small baseline of transport, Git, archive, JSON,
terminal, editor, and sync packages.
