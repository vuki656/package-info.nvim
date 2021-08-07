local DEFAULT_OPTIONS = {
    colors = {
        up_to_date = "#89ca78",
        outdated = "#ef596f",
    },
    icons = {
        enable = true,
        style = {
            up_to_date = "|  ",
            outdated = "|  ",
        },
    },
}

local register_highlight_group = function(group, color)
    vim.cmd("highlight " .. group .. " guifg=" .. color .. " gui=italic")
end

local M = {}

M.highlight_groups = {
    outdated = "PackageInfoOutdatedVersion",
    up_to_date = "PackageInfoUpToDateVersion",
}

-- Clone options and replace empty ones with default ones
M.setup_options = function(options)
    M.options = vim.tbl_deep_extend("force", {}, DEFAULT_OPTIONS, options or {})
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
    register_highlight_group(M.highlight_groups.outdated, M.options.colors.outdated)
    register_highlight_group(M.highlight_groups.up_to_date, M.options.colors.up_to_date)
end

return M
