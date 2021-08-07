local M = {}

-- Get latest version for a given package
function M:get_latest_package_version(package_name, callback)
    local command = "npm show " .. package_name .. " version"

    vim.fn.jobstart(command, {
        on_stdout = function(_, stdout)
            local latest_package_version = table.concat(stdout)

            callback(latest_package_version)
        end,
    })
end

return M
