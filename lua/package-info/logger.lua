local M = {}

M.__print = function(message, highlight_group)
    vim.api.nvim_echo({ { "PackageInfo: " .. message, highlight_group or "" } }, {}, {})
end

M.error = function(message)
    M.__print(message, "ErrorMsg")
end

M.warn = function(message)
    M.__print(message, "WarningMsg")
end

M.info = function(message)
    M.__print(message)
end

return M
