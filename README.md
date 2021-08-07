# ✍️ Package Info

Displays latest package versions in your `package.json` file as virtual text.

![Package Info Screenshot](./media/screen.png)

## ✨ Features

- Display latest package versions as virtual text

## ✨ Planned Features

- Upgrade package on current line
- Delete package on current line
- Install custom package version trough input popup
- Install new packages trough search popup

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

### Setup

Package Info comes with the following defaults:

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

## 🚀 Usage

### Keybindings

Package info comes with the following default commands:

- `<leader>pus` => Show latest package versions
- `<leader>puc` => Clear package info versions

Remapping

```lua
-- Display latest versions as virtual text
vim.api.nvim_set_keymap("n", "<leader>xxx", "<cmd>lua require('package-info').display()<cr>",
  { silent = true, noremap = true }
)

-- Clear package info virtual text
vim.api.nvim_set_keymap("n", "<leader>xxx", "<cmd>lua require('package-info').clear()<cr>",
  { silent = true, noremap = true }
)
```

### Notes

- Display might be slow on a project with a lot of packages. This is due to the
`npm outdated` command taking a long time. Nothing can be done regarding
that on the plugin side.

- Idea was inspired by [akinso](https://github.com/akinsho) and his [dependency-assist.nvim](Dependency-assist.nvim)

- Readme template stolen from [folke](https://github.com/folke)

- This is my first `neovim` plugin so please don't hesitate to
open an issue an tell me if you find any stupid stuff in the code :D.

