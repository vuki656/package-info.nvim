# ✍️ Package Info

Displays latest package versions in your `package.json` file as virtual text.

![Package Info Screenshot](./media/screen.png)

## ✨ Features

- Display latest package versions as virtual text

## 🚀 Planned Features

- Install new packages trough search popup [#26](https://github.com/vuki656/package-info.nvim/issues/26)
- Upgrade package on current line [#21](https://github.com/vuki656/package-info.nvim/issues/21)
- Install custom package version trough popup [#24](https://github.com/vuki656/package-info.nvim/issues/24)
- Delete package on current line [#23](https://github.com/vuki656/package-info.nvim/issues/23)
- Set package manager [#22](https://github.com/vuki656/package-info.nvim/issues/22)

## ⚡️ Requirements

- Neovim >= 0.5.0
- Npm
- [Patched font](https://github.com/ryanoasis/nerd-fonts/tree/gh-pages) if you
want icons

## 📦 Installation

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
use { "vuki656/package-info.nvim" }
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
}
```

## ⌨️  Keybindings

**Package info has no default Keybindings**.

You can copy the ones below:

```lua
-- Display latest versions as virtual text
vim.api.nvim_set_keymap("n", "<leader>ns", "<cmd>lua require('package-info').show()<cr>",
  { silent = true, noremap = true }
)

-- Clear package info virtual text
vim.api.nvim_set_keymap("n", "<leader>nc", "<cmd>lua require('package-info').hide()<cr>",
  { silent = true, noremap = true }
)
```

## 📝 Notes

- Display might be slow on a project with a lot of packages. This is due to the
`npm outdated` command taking a long time. Nothing can be done regarding
that on the plugin side.

- Idea was inspired by [akinsho](https://github.com/akinsho) and his [dependency-assist.nvim](Dependency-assist.nvim)

- Readme template stolen from [folke](https://github.com/folke)

- This is my first `neovim` plugin so please don't hesitate to
open an issue an tell me if you find any stupid stuff in the code :D.

