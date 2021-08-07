local CONSTANTS = require("package-info.utils.constants")
local helpers = require("package-info.utils.helpers")

local M = {}

-- Clone options and replace empty ones with default ones
M.setup_options = function(options)
    M.options = vim.tbl_deep_extend("force", {}, CONSTANTS.DEFAULT_OPTIONS, options or {})
end

-- Register autocommand for auto-starting plugin
M.register_auto_start = function()
    vim.api.nvim_exec(
        [[augroup PackageUI
            autocmd!
            autocmd BufWinEnter,WinNew * lua require("package-info").start()
        augroup end]],
        false
    )
end

-- Set highlight groups
M.register_highlights = function()
    helpers.register_highlight_group(CONSTANTS.HIGHLIGHT_GROUPS.outdated, M.options.colors.outdated)
    helpers.register_highlight_group(CONSTANTS.HIGHLIGHT_GROUPS.up_to_date, M.options.colors.up_to_date)
end

return M
