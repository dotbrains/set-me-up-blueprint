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
adapter = "rcm"

[profile.default]
modules = ["example"]
```

Use `rcm` for shell/Brewfile/packages modules and thoughtbot `rcm` dotfile
symlinks. Use `home-manager` when modules publish a Home Manager implementation
in `module.toml`; `smu provisioning-adapter apply --adapter home-manager
--profile default` writes the generated Home Manager import file and runs
`home-manager switch`.

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
