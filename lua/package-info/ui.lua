local config = require("package-info.config")
local CONSTANTS = require("package-info.utils.constants")
local API = require("package-info.api")

local M = {}

-- Set latest version as virtual text for each dependency
M.set_virtual_text = function(dependencies, dependency_positions)
    for package_name, current_package_version in pairs(dependencies) do
        API:get_latest_package_version(package_name, function(latest_package_version)
            -- Remove ^ from version
            local cleaned_version = string.gsub(current_package_version, "%^", "", 1)

            local highlight = {
                group = CONSTANTS.HIGHLIGHT_GROUPS.up_to_date,
                icon = config.options.icons.style.up_to_date,
            }

            if latest_package_version ~= cleaned_version then
                highlight.group = CONSTANTS.HIGHLIGHT_GROUPS.outdated
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
