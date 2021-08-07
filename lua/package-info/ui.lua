local config = require("package-info.config")
local API = require("package-info.api")

local M = {}

-- Set latest version as virtual text for each dependency
M.set_virtual_text = function(dependencies, dependency_positions)
    for package_name, current_package_version in pairs(dependencies) do
        API:get_latest_package_version(package_name, function(latest_package_version)
            local highlight = {
                group = config.highlight_groups.up_to_date,
                icon = config.options.icons.style.up_to_date,
            }

            if latest_package_version ~= current_package_version then
                highlight.group = config.highlight_groups.outdated
                highlight.icon = config.options.icons.style.outdated
            end

            if config.options.icons.enable == false then
                highlight.icon = ""
            end

            vim.api.nvim_buf_set_virtual_text(
                0,
                0,
                dependency_positions[package_name],
                { { highlight.icon .. latest_package_version, highlight.group } },
                {}
            )
        end)
    end
end

return M
