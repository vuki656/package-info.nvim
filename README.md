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

- Display latest dependency versions as virtual text
- Upgrade dependency on current line to latest version
- Delete dependency on current line
- Install a different version of a dependency on current line
- Install new dependency
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

### Delete Dependency

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

Runs `npm install dependency@version`, `yarn upgrade dependency@version`, or `pnpm update dependency` in the background and reloads the buffer.

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

### Install New Dependency

<img src="https://github.com/vuki656/vuki656/blob/master/media/package-info/install.gif" width=500>

Runs `npm install dependency`, `yarn add dependency`, or `pnpm add dependency` in the background and reloads the buffer.

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

### Loading Hook

<img src="https://github.com/vuki656/vuki656/blob/master/media/package-info/loading.gif" width=500>

Function that can be placed anywhere to display the loading status from the plugin.

</div>

#### Usage

- It can be used anywhere in `neovim` by invoking `return require('package-info').get_status()`

```lua
local package_info = require("package-info")

-- Galaxyline
section.left[10] = {
    PackageInfoStatus = {
        provider = function()
            return package_info.get_status()
        end,
    },
}

-- Feline
components.right.active[5] = {
    provider = function()
        return package_info.get_status()
    end,
    hl = {
        style = "bold",
    },
    left_sep = "  ",
    right_sep = " ",
}
```

## ⚡️ Requirements

- Neovim >= 0.6.0
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
        up_to_date = "#3C4048", -- Text color for up to date dependency virtual text
        outdated = "#d19a66", -- Text color for outdated dependency virtual text
    },
    icons = {
        enable = true, -- Whether to display icons
        style = {
            up_to_date = "|  ", -- Icon for up to date dependencies
            outdated = "|  ", -- Icon for outdated dependencies
        },
    },
    autostart = true, -- Whether to autostart when `package.json` is opened
    hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
    hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
    -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
    -- The plugin will try to auto-detect the package manager based on
    -- `yarn.lock` or `package-lock.json`. If none are found it will use the
    -- provided one, if nothing is provided it will use `yarn`
    package_manager = 'yarn'
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

**Plugin has no default Keybindings**.

You can copy the ones below:

```lua
-- Show dependency versions
vim.keymap.set({ "n" }, "<LEADER>ns", require("package-info").show, { silent = true, noremap = true })

-- Hide dependency versions
vim.keymap.set({ "n" }, "<LEADER>nc", require("package-info").hide, { silent = true, noremap = true })

-- Toggle dependency versions
vim.keymap.set({ "n" }, "<LEADER>nt", require("package-info").toggle, { silent = true, noremap = true })

-- Update dependency on the line
vim.keymap.set({ "n" }, "<LEADER>nu", require("package-info").update, { silent = true, noremap = true })

-- Delete dependency on the line
vim.keymap.set({ "n" }, "<LEADER>nd", require("package-info").delete, { silent = true, noremap = true })

-- Install a new dependency
vim.keymap.set({ "n" }, "<LEADER>ni", require("package-info").install, { silent = true, noremap = true })

-- Install a different dependency version
vim.keymap.set({ "n" }, "<LEADER>np", require("package-info").change_version, { silent = true, noremap = true })
```

## 🔭 Telescope

> Highly inspired by [telescope-lazy.nvim](https://github.com/tsakirist/telescope-lazy.nvim)

### Configuration

```lua
require("telescope").setup({
    extensions = {
        package_info = {
            -- Optional theme (the extension doesn't set a default theme)
            theme = "ivy",
        },
    },
})

require("telescope").load_extension("package_info")
```

### Available Commands

```
:Telescope package_info
```

## 📝 Notes

- Display might be slow on a project with a lot of dependencies. This is due to the
  `npm outdated --json` command taking a long time. Nothing can be done about that
- Idea was inspired by [akinsho](https://github.com/akinsho) and his [dependency-assist.nvim](https://github.com/akinsho/dependency-assist.nvim)
- Readme template stolen from [folke](https://github.com/folke)
