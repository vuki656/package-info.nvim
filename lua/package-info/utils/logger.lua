local M = {}

--- Prints a message with a given highlight group
-- @param message: string - message to print
-- @param highlight_group: string - highlight group to use when printing the message
-- @return nil
M.__print = function(message, highlight_group)
    vim.api.nvim_echo({ { "PackageInfo: " .. message, highlight_group or "" } }, {}, {})
end

--- Prints an error message
--- For notifying the user about a critical failure
-- @param message: string - error message to print
-- @return nil
M.error = function(message)
    M.__print(message, "ErrorMsg")
end

--- Prints a warning message
--- For notifying the user about a non critical failure
-- @param message: string - warning message to print
-- @return nil
M.warn = function(message)
    M.__print(message, "WarningMsg")
end

--- Prints an info message
--- For notifying the user about something not important
-- @param message: string - info message to print
-- @return nil
M.info = function(message)
    M.__print(message)
end

return M
