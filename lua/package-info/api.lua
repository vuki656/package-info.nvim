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
    })
end

return M
