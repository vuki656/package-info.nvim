local M = {}

--- Prints a message with a given highlight group
-- @param message: string - message to print
-- @param highlight_group: string - highlight group to use when printing the message
-- @return nil
M.__print = function(message, highlight_group)
    if pcall(require, "notify") or pcall(require, "snacks.notifier") then
        if not highlight_group then
            highlight_group = "InfoMsg"
        end

        local level = {
            ["InfoMsg"] = {
                log_level = vim.log.levels.INFO,
                log_symbol = "󰗠 ",
            },
            ["ErrorMsg"] = {
                log_level = vim.log.levels.ERROR,
                log_symbol = "󰅙 ",
            },
            ["WarningMsg"] = {
                log_level = vim.log.levels.WARN,
                log_symbol = " ",
            },
        }
        vim.notify(message, level[highlight_group].log_level, {
            title = "package-info.nvim",
            icon = level[highlight_group].log_symbol,
            timeout = 3000,
        })
    else
        vim.api.nvim_echo({ { "PackageInfo: " .. message, highlight_group or "" } }, true, {})
    end
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
