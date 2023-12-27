# `set-me-up` blueprint

A template to manage your [`set-me-up`](https://github.com/nicholasadamou/set-me-up) setup that is loosely coupled.

## What's inside

1.  A `rcm` tag called [my](.dotfiles/tag-my) and an adapted `rcrc` file.
2.  [Your own module](.dotfiles/modules/my) called `my`. You can go crazy with your customizations here.
3.  [Installer](.dotfiles/modules/install.sh) that is required to download `set-me-up` on top of your blueprint.

## How to use

1.  [Read the docs](https://github.com/nicholasadamou/set-me-up#set-me-up).
2.  Fork this repository.
3.  Add your customizations inside the [tag-example](.dotfiles/tag-example).
4.  Change the [`SMU_BLUEPRINT` variable value](.dotfiles/modules/install.sh#L5) to your GitHub `user\repo` combination.
5.  Change the [`SMU_VERSION` variable value](.dotfiles/modules/install.sh#L7) to either one of the following options.

    ⚠️ Please note that [`set-me-up`](https://github.com/nicholasadamou/set-me-up) has **two** different _branches_.

    1.  **`master`** - Used if host device is Macintosh-based.

    2.  **`debian`** - Used if host device is debian-based.

6.  Use the [installer](.dotfiles/modules/install.sh) to obtain `set-me-up` and your blueprint setup by changing the following within the below snippet:

    1.  **_YOUR-USERNAME_** - This should be changed to your `GitHub` username.

    2.  **_BRANCH-NAME-HERE_** - This should be changed based on the host device's kernel.

    ```bash
    bash <(curl -s -L https://raw.githubusercontent.com/<YOUR-USERNAME>/set-me-up-blueprint/<BRANCH-NAME-HERE>/.dotfiles/modules/install.sh)
    ```
