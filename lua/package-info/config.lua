-- FILE DESCRIPTION: User passed config options

local constants = require("package-info.constants")
local globals = require("package-info.globals")

----------------------------------------------------------------------------
---------------------------------- HELPERS ---------------------------------
----------------------------------------------------------------------------

local DEFAULT_OPTIONS = {
    colors = {
        up_to_date = "#3C4048",
        outdated = "#d19a66",
    },
    icons = {
        enable = true,
        style = {
            up_to_date = "|  ",
            outdated = "|  ",
        },
    },
    autostart = true,
}
local highlight_param = "guifg"
if not vim.o.termguicolors then
    highlight_param = "ctermfg"
    DEFAULT_OPTIONS.colors = {
        up_to_date = "237",
        outdated = "173",
    }
end

local register_highlight_group = function(group, color)
    vim.cmd("highlight " .. group .. " " .. highlight_param .. "=" .. color)
end

local register_colorscheme_autocmd = function()
    vim.cmd([[
      augroup PackageInfoHighlight
        autocmd!
        autocmd ColorScheme * lua require('package-info').register_highlight_groups()
      augroup END
    ]])
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
M.register_highlight_groups = function()
    register_highlight_group(constants.HIGHLIGHT_GROUPS.outdated, M.options.colors.outdated)
    register_highlight_group(constants.HIGHLIGHT_GROUPS.up_to_date, M.options.colors.up_to_date)
end

M.setup = function(options)
    M.options = register_user_options(options)

    register_autostart(M.options.autostart)
    register_colorscheme_autocmd()
    M.register_highlight_groups()
    globals.namespace.register()
end
return M
