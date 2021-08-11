-- FILE DESCRIPTION: User passed config options

local constants = require("package-info.constants")
local globals = require("package-info.globals")

----------------------------------------------------------------------------
---------------------------------- HELPERS ---------------------------------
----------------------------------------------------------------------------

local DEFAULT_OPTIONS = {
    icons = {
        enable = true,
        style = {
            up_to_date = "|  ",
            outdated = "|  ",
        },
    },
    autostart = true,
}
if vim.o.termguicolors then
  -- Hex rgb colors for truecolor terminals
  HIGHLIGHT_PARAM = "guifg"
  DEFAULT_OPTIONS.colors = {
    up_to_date = "#3C4048",
    outdated = "#d19a66",
  }
else
  -- Numbered colors for 256 color terminals
  HIGHLIGHT_PARAM = "ctermfg"
  -- https://jonasjacek.github.io/colors/
  DEFAULT_OPTIONS.colors = {
    up_to_date = "237", -- cterm Grey237
    outdated = "173", -- cterm LightSalmon3
  }
end

local register_highlight_group = function(group, color)
    vim.cmd("highlight " .. group .. " " .. HIGHLIGHT_PARAM .. "=" .. color)
end

local register_highlight_groups = function(colors)
    register_highlight_group(constants.HIGHLIGHT_GROUPS.outdated, colors.outdated)
    register_highlight_group(constants.HIGHLIGHT_GROUPS.up_to_date, colors.up_to_date)
end

-- Register autocommand for auto-starting plugin
local register_autostart = function(should_autostart)
    if should_autostart then
        vim.api.nvim_exec(
            [[augroup PackageUI
                autocmd!
                autocmd BufWinEnter,WinNew * lua require("package-info").show()
            augroup end]],
            false
        )
    end
end

-- Clone options and replace empty ones with default ones
local register_user_options = function(options)
    return vim.tbl_deep_extend("force", {}, DEFAULT_OPTIONS, options or {})
end

----------------------------------------------------------------------------
---------------------------------- MODULE ----------------------------------
----------------------------------------------------------------------------

local M = {}

M.setup = function(options)
    M.options = register_user_options(options)

    register_autostart(M.options.autostart)
    register_highlight_groups(M.options.colors)

    globals.namespace.register()
end

M.highlight_groups = register_highlight_groups -- XXX Weird hack

return M
