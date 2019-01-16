# `set-me-up` blueprint

A template to manage your [`set-me-up`](https://github.com/nicholasadamou/set-me-up) setup that is loosely coupled.

## What's inside

1.  A `rcm` tag called [my](.dotfiles/tag-my) and an adapted `rcrc` file.
2.  [Your own module](.dotfiles/tag-my/modules/my) called `my`. You can go crazy with your customizations here.
3.  [Installer](.dotfiles/tag-my/modules/install.sh) that is required to download `set-me-up` on top of your blueprint.

## How to use

1.  [Read the docs](https://github.com/nicholasadamou/set-me-up#set-me-up)
2.  Fork this repository.
3.  Add your customizations inside the [my tag](.dotfiles/tag-my).
4.  Change the [`SMU_BLUEPRINT` variable value](.dotfiles/tag-my/modules/install.sh#L5) to your GitHub `user\repo` combination.
5.  Change the [`SMU_VERSION` variable value](.dotfiles/tag-my/modules/install.sh#L7) to either one of the following options.

    1. **`master`** if on a Macintosh-based device.

    2. **`debian`** if on a debian-based device.

    ⚠️ More on this in step 6 below.

6.  Use the installer to obtain `set-me-up` and your blueprint setup.

    ⚠️ Please note that [`set-me-up`](https://github.com/nicholasadamou/set-me-up) has **two** different _branches_.

    1.  **`master`** - Used if host device is Macintosh-based.

    2.  **`debian`** - Used if host device is debian-based.

    Thus, change the following in the below snippet:

    1.  **_BRANCH-NAME-HERE_** - This should be changed based on the host device's kernel.

    2.  **_YOUR-USERNAME_** - This should be changed to your `GitHub` username.

    ```bash
    bash <(curl -s -L https://raw.githubusercontent.com/<YOUR-USERNAME>/set-me-up-blueprint/<BRANCH-NAME-HERE>/.dotfiles/tag-my/modules/install.sh) --git
    ```

    ⚠️ Lastly, please note that the installer has **three** different arguments:

    1.  **`--curl`** - When this is passed, it will obtain the `smu` blueprint via `curl`.

    _However_, It is recommended to use `--git` instead, because of the use of `git submodules`.

    2.  **`--git`** - When this is passed, it will obtain the `smu` blueprint via `git`.

    3.  **`--detect`** - When this is passed, it will _detect_ if the `smu` blueprint was either obtained using `git` or `curl`. If it wasn't obtained using `git` it will use `curl` or visa-versa.
