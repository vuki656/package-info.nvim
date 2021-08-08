local CONSTANTS = require("package-info.utils.constants")
local helpers = require("package-info.utils.helpers")

local M = {}

-- Clone options and replace empty ones with default ones
M.setup_options = function(options)
    M.options = vim.tbl_deep_extend("force", {}, CONSTANTS.DEFAULT_OPTIONS, options or {})
end

-- Register autocommand for auto-starting plugin
M.register_auto_start = function()
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

-- Set highlight groups
M.register_highlights = function()
    M.namespace_id = vim.api.nvim_create_namespace("package-ui")

    helpers.register_highlight_group(CONSTANTS.HIGHLIGHT_GROUPS.outdated, M.options.colors.outdated)
    helpers.register_highlight_group(CONSTANTS.HIGHLIGHT_GROUPS.up_to_date, M.options.colors.up_to_date)
end

return M
