-- DESCRIPTION: sets up the user given configuration

local constants = require("package-info.constants")
local globals = require("package-info.globals")

----------------------------------------------------------------------------
---------------------------------- MODULE ----------------------------------
----------------------------------------------------------------------------

local M = {}

--- Default options
M.options = {
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

    __highlight_params = {
        fg = "guifg",
    },
}

--- Clone options and replace empty ones with default ones
M.__register_user_options = function(user_options)
    return vim.tbl_deep_extend("force", {}, M.options, user_options or {})
end

--- Register autocommand for auto-starting plugin
M.__register_autostart = function()
    if M.options.autostart then
        vim.api.nvim_exec(
            [[augroup PackageUI
                autocmd!
                autocmd BufWinEnter,WinNew * lua require("package-info").show()
            augroup end]],
            false
        )
    end
end

--- If terminal doesn't support true color, fallback to 256 config
M.__register_256color_support = function()
    if not vim.o.termguicolors then
        vim.cmd([[
          augroup PackageUIHighlight
            autocmd!
            autocmd ColorScheme * lua require('package-info.config').__register_highlight_groups()
          augroup END
        ]])

        M.options.colors = {
            up_to_date = "237",
            outdated = "173",
        }

        M.options.__highlight_params.fg = "ctermfg"
    end
end

--- Register given highlight group
-- @param group - highlight group
-- @param color - color to use with the highlight group
M.__register_highlight_group = function(group, color)
    vim.cmd("highlight " .. group .. " " .. M.options.__highlight_params.fg .. "=" .. color)
end

--- Register all highlight groups
M.__register_highlight_groups = function()
    M.__register_highlight_group(constants.HIGHLIGHT_GROUPS.outdated, M.options.colors.outdated)
    M.__register_highlight_group(constants.HIGHLIGHT_GROUPS.up_to_date, M.options.colors.up_to_date)
end

--- Take all user options and setup the config
-- @param user_options - all the options user can provide in the plugin config // See M.options for defaults
M.setup = function(user_options)
    M.__register_user_options(user_options)
    M.__register_autostart()
    M.__register_256color_support()
    M.__register_highlight_groups()

    globals.namespace.register()
end

return M
