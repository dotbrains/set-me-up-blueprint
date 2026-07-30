# `set-me-up` blueprint

[![License: PolyForm Shield 1.0.0](https://img.shields.io/badge/License-PolyForm%20Shield%201.0.0-blue.svg)](https://polyformproject.org/licenses/shield/1.0.0)

A template to manage your personal `set-me-up` setup. A blueprint is the
repository users install; `smu` and the shared module repositories provide the
reusable installer behavior.

## What's inside

1.  A `rcm` tag called [example](../dotfiles/tag-example) and an adapted `rcrc` file.
2.  [Your own module](../dotfiles/modules/example) called `example`. You can go crazy with your customizations here.
3.  [Installer](../dotfiles/modules/install.sh) that is required to download `set-me-up` on top of your blueprint.

## How to use

1.  [Read the docs](https://github.com/dotbrains/set-me-up-docs).
2.  Fork this repository.
3.  Add your customizations inside the [tag-example](../dotfiles/tag-example).
4.  Change the [`SMU_BLUEPRINT` variable value](../dotfiles/modules/install.sh#L5) to your GitHub `user\repo` combination.

5.  Use the [installer](../dotfiles/modules/install.sh) to obtain your
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
bash <(curl -s -L https://raw.githubusercontent.com/<YOUR-USERNAME>/set-me-up-blueprint/<BRANCH-NAME-HERE>/dotfiles/modules/install.sh) --plan
```

Test an installer candidate branch before it is published to `main`:

```bash
SMU_INSTALLER_REF=my-branch bash <(curl -s -L https://raw.githubusercontent.com/<YOUR-USERNAME>/set-me-up-blueprint/<BRANCH-NAME-HERE>/dotfiles/modules/install.sh) --plan
```

Routine updates should use `smu` from the installed checkout:

```bash
smu update blueprint   # update your blueprint repository
smu update installer   # update the smu installer repository
smu update modules     # update blueprint submodules
smu update --all       # update blueprint, installer, modules, and generated config
```

If you intentionally want to discard local blueprint changes during bootstrap
or update, pass `--force-reset`.
