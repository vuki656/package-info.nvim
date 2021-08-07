local CONSTANTS = require("package-info.utils.constants")

local config = require("package-info.config")
local helpers = require("package-info.utils.helpers")

-- Determine if package is outdated and return meta about it accordingly
local get_package_metadata = function(current_package_version, outdated_dependencies, package_name)
    local package_metadata = {
        group = CONSTANTS.HIGHLIGHT_GROUPS.up_to_date,
        icon = config.options.icons.style.up_to_date,
        version = current_package_version,
    }

    if outdated_dependencies[package_name] then
        package_metadata = {
            version = outdated_dependencies[package_name].latest,
            group = CONSTANTS.HIGHLIGHT_GROUPS.outdated,
            icon = config.options.icons.style.outdated,
        }
    end

    if config.options.icons.enable == false then
        package_metadata.icon = ""
    end

    return package_metadata
end

local M = {}

-- Set latest version as virtual text for each dependency
M.set_virtual_text = function(dependencies, dependency_positions, outdated_dependencies)
    local is_file_package_json = helpers.is_file_package_json()

    if not is_file_package_json then
        return
    end

    for package_name, current_package_version in pairs(dependencies) do
        local package_metadata = get_package_metadata(current_package_version, outdated_dependencies, package_name)

        vim.api.nvim_buf_set_extmark(0, config.namespace_id, dependency_positions[package_name], 0, {
            virt_text = { { package_metadata.icon .. package_metadata.version, package_metadata.group } },
            virt_text_pos = "eol",
            priority = 200,
        })
    end
end

return M
