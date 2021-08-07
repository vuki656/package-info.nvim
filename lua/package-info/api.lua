local json_parser = require("package-info.libs.json_parser")

local M = {}

-- Get latest version for a given package
function M:get_outdated_dependencies(callback)
    local command = "npm outdated --json"
    local done = false -- TODO: Create issue

    vim.fn.jobstart(command, {
        on_stdout = function(_, stdout)
            if done == false then
                local string_value = table.concat(stdout)
                local json_value = json_parser.decode(string_value)

                callback(json_value)
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
