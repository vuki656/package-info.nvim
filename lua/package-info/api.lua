local json_parser = require("package-info.libs.json_parser")

local M = {}

local done = false -- TODO: Create issue

-- Get latest version for a given package
function M:get_outdated_dependencies(callback)
    local string_value = ""
    local command = "npm outdated --json"

    vim.fn.jobstart(command, {
        on_stdout = function(_, stdout)
            local partial_string_value = table.concat(stdout)
            string_value = string_value .. partial_string_value
        end,

        on_exit = function(_, __, ___)
            if done == false then
                local json_value = json_parser.decode(string_value)
                callback(json_value)
                local string_value = ""
            end

            done = true
        end,

        on_stderr = function(_, stderr)
            if stderr[0] ~= nil then
                vim.api.nvim_echo({ { "Package info retrieval failed.", "WarningMsg" } }, {}, {})
            end
        end,
    })
end

return M
