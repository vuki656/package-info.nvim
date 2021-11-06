<div align="center">

<img src="https://github.com/vuki656/vuki656/blob/master/media/package-info/logo.png" width=315>

## All the `npm`/`yarn`/`pnpm` commands I don't want to type

</div>

<div align="center">

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua&logoColor=white)

</div>

<div align="center">

![License](https://img.shields.io/badge/License-GPL%20v3-brightgreen?style=flat-square)
![Status](https://img.shields.io/badge/Status-Beta-informational?style=flat-square)
![Neovim](https://img.shields.io/badge/Neovim-0.5+-green.svg?style=flat-square&logo=Neovim&logoColor=white)

</div>

## ✨ Features

- Display latest package versions as virtual text
- Upgrade package on current line to latest version
- Delete package on current line
- Install a different version of a package on current line
- Install new package
- Reinstall dependencies
- Automatic package manager detection
- Loading animation hook (to be placed in status bar or anywhere else)

<div align="center">

### Display Latest Package Version

<img src="https://github.com/vuki656/vuki656/blob/master/media/package-info/display.gif" width=500>

Runs `npm outdated --json` in the background and then compares the output with versions in `package.json` and displays them as virtual text.

</div>

#### Keybinding

```lua
vim.api.nvim_set_keymap(
    "n",
    "<leader>ns",
    "<cmd>lua require('package-info').show()<cr>",
    { silent = true, noremap = true }
)
```

- **NOTE:** after the first outdated dependency fetch, it will show the cached results for the next hour instead of re-fetching every time.
- If you would like to force re-fetching every time you can provide `force = true` like in the example below:

```lua
vim.api.nvim_set_keymap(
    "n",
    "<leader>ns",
    "<cmd>lua require('package-info').show({ force = true })<cr>",
    { silent = true, noremap = true }
)
```

<div align="center">

### Delete Package

<img src="https://github.com/vuki656/vuki656/blob/master/media/package-info/delete.gif" width=500>

Runs `yarn remove`, `npm uninstall`, or `pnpm uninstall` in the background and reloads the buffer.

</div>

#### Keybinding

```lua
vim.api.nvim_set_keymap(
    "n",
    "<leader>nd",
    "<cmd>lua require('package-info').delete()<cr>",
    { silent = true, noremap = true }
)
```

<div align="center">

### Install Different Version

<img src="https://github.com/vuki656/vuki656/blob/master/media/package-info/change.gif" width=500>

Runs `npm install package@version`, `yarn upgrade package@version`, or `pnpm update package` in the background and reloads the buffer.

</div>

#### Keybinding

```lua
vim.api.nvim_set_keymap(
    "n",
    "<leader>np",
    "<cmd>lua require('package-info').change_version()<cr>",
    { silent = true, noremap = true }
)
```

<div align="center">

### Install New Package

<img src="https://github.com/vuki656/vuki656/blob/master/media/package-info/install.gif" width=500>

Runs `npm install package`, `yarn add package`, or `pnpm add package` in the background and reloads the buffer.

</div>

#### Keybinding

```lua
vim.api.nvim_set_keymap(
    "n",
    "<leader>ni",
    "<cmd>lua require('package-info').install()<cr>",
    { silent = true, noremap = true }
)
```

<div align="center">

### Reinstall Dependencies

<img src="https://github.com/vuki656/vuki656/blob/master/media/package-info/reinstall.gif" width=500>

Runs `rm -rf node_modules && yarn`, `rm -rf node_modules && npm install`, or `rm -rf node_modules && pnpm install` in the background and reloads the buffer.

</div>

#### Keybinding

```lua
vim.api.nvim_set_keymap(
    "n",
    "<leader>nr",
    "<cmd>lua require('package-info').reinstall()<cr>",
    { silent = true, noremap = true }
)
```

<div align="center">

### Loading Hook

<img src="https://github.com/vuki656/vuki656/blob/master/media/package-info/loading.gif" width=500>

Function that can be placed anywhere to display the loading status from the plugin.

</div>

#### Usage

- It can be used anywhere in `neovim` by invoking `return require('package-info').get_status()`

```lua
local package = require("package-info")

-- Galaxyline
section.left[10] = {
    PackageInfoStatus = {
        provider = function()
            return package.get_status()
        end,
    },
}

-- Feline
components.right.active[5] = {
    provider = function()
        return package.get_status()
    end,
    hl = {
        style = "bold",
    },
    left_sep = "  ",
    right_sep = " ",
}
```

## ⚡️ Requirements

- Neovim >= 0.5.0
- Npm
- [Patched font](https://github.com/ryanoasis/nerd-fonts/tree/gh-pages) if you want icons

## 📦 Installation

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
use({
    "vuki656/package-info.nvim",
    requires = "MunifTanjim/nui.nvim",
})
```

## ⚙️ Configuration

### Usage

```lua
require('package-info').setup()
```

### Defaults

```lua
{
    colors = {
        up_to_date = "#3C4048", -- Text color for up to date package virtual text
        outdated = "#d19a66", -- Text color for outdated package virtual text
    },
    icons = {
        enable = true, -- Whether to display icons
        style = {
            up_to_date = "|  ", -- Icon for up to date packages
            outdated = "|  ", -- Icon for outdated packages
        },
    },
    autostart = true -- Whether to autostart when `package.json` is opened
    hide_up_to_date = true -- It hides up to date versions when displaying virtual text
    hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
    -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
    -- The plugin will try to auto-detect the package manager based on
    -- `yarn.lock` or `package-lock.json`. If none are found it will use the
    -- provided one, if nothing is provided it will use `yarn`
    package_manager = `yarn`
}
```

#### 256 Color Terminals

- If the vim option `termguicolors` is false, package-info switches to 256 color mode.
- In this mode [cterm color numbers](https://jonasjacek.github.io/colors/) are used
  instead of truecolor hex codes and the color defaults are:

```lua
colors = {
    up_to_date = "237", -- cterm Grey237
    outdated = "173", -- cterm LightSalmon3
}
```

## ⌨️ All Keybindings

**Package info has no default Keybindings**.

You can copy the ones below:

```lua
-- Show package versions
vim.api.nvim_set_keymap("n", "<leader>ns", ":lua require('package-info').show()<CR>", { silent = true, noremap = true })

-- Hide package versions
vim.api.nvim_set_keymap("n", "<leader>nc", ":lua require('package-info').hide()<CR>", { silent = true, noremap = true })

-- Update package on line
vim.api.nvim_set_keymap("n", "<leader>nu", ":lua require('package-info').update()<CR>", { silent = true, noremap = true })

-- Delete package on line
vim.api.nvim_set_keymap("n", "<leader>nd", ":lua require('package-info').delete()<CR>", { silent = true, noremap = true })

-- Install a new package
vim.api.nvim_set_keymap("n", "<leader>ni", ":lua require('package-info').install()<CR>", { silent = true, noremap = true })

-- Reinstall dependencies
vim.api.nvim_set_keymap("n", "<leader>nr", ":lua require('package-info').reinstall()<CR>", { silent = true, noremap = true })

-- Install a different package version
vim.api.nvim_set_keymap("n", "<leader>np", ":lua require('package-info').change_version()<CR>", { silent = true, noremap = true })
```

## 📝 Notes

- If you want to test out new features use the `develop` branch. `master` should be stable and tested by me. I test features
  on develop for a couple of days before merging them to master

- Display might be slow on a project with a lot of packages. This is due to the
  `npm outdated` command taking a long time. Nothing can be done about that

- Idea was inspired by [akinsho](https://github.com/akinsho) and his [dependency-assist.nvim](https://github.com/akinsho/dependency-assist.nvim)

- Readme template stolen from [folke](https://github.com/folke)

- This is my first `neovim` plugin so please don't hesitate to open an issue an tell me if you find anything stupid in the code :D.
