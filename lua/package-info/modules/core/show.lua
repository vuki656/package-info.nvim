-- FILE DESCRIPTION: Functionality related to showing latest package versions as virtual text

local json_parser = require("package-info.libs.json_parser")

local constants = require("package-info.constants")
local config = require("package-info.config")
local globals = require("package-info.globals")

local utils = require("package-info.utils")

----------------------------------------------------------------------------
---------------------------------- HELPERS ---------------------------------
----------------------------------------------------------------------------

-- Checks if the open buffer refers to a non-empty package.json file
local is_valid_package_json = function()
    local current_buffer_name = vim.api.nvim_buf_get_name(0)
		-- Check name
		local is_package_json = string.match(current_buffer_name, "package.json$")
		-- Check if empty
		local buffer_size = vim.fn.getfsize(current_buffer_name)
		-- Ensure package.json is non-empty
		return is_package_json and buffer_size > 0
end

-- Determine if package is outdated and return meta about it accordingly
local get_package_metadata = function(current_package_version, outdated_dependencies, package_name)
    local package_metadata = {
        group = constants.HIGHLIGHT_GROUPS.up_to_date,
        icon = config.options.icons.style.up_to_date,
        version = current_package_version,
    }

    if outdated_dependencies[package_name] then
        package_metadata = {
            version = outdated_dependencies[package_name].latest,
            group = constants.HIGHLIGHT_GROUPS.outdated,
            icon = config.options.icons.style.outdated,
        }
    end

    if config.options.icons.enable == false then
        package_metadata.icon = ""
    end

    return package_metadata
end

local set_virtual_text = function(dependencies, outdated_dependencies)
    -- may be an unnecessary check
		if not is_valid_package_json() then
        return
    end

    local dependency_positions = utils.buffer.get_dependency_positions()

    for package_name, current_package_version in pairs(dependencies) do
        local package_metadata = get_package_metadata(current_package_version, outdated_dependencies, package_name)

        local virtual_text = package_metadata.icon .. package_metadata.version
        local position = dependency_positions[package_name]

        vim.api.nvim_buf_set_extmark(0, globals.namespace.id, position, 0, {
            virt_text = { { virtual_text, package_metadata.group } },
            virt_text_pos = "eol",
            priority = 200,
        })
    end
end

local get_outdated_dependencies = function(callback)
    local command = "npm outdated --json"

    -- https://github.com/vuki656/package-info.nvim/issues/19
    local done = false

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

----------------------------------------------------------------------------
------------------------------ RETURN FUNCTION -----------------------------
----------------------------------------------------------------------------

-- Contains functionality needed in order to set the virtual text
return function()
		if not is_valid_package_json() then
				return
		end

		local dev_dependencies, prod_dependencies, peer_dependencies = utils.buffer.get_dependencies()

		get_outdated_dependencies(function(outdated_dependencies)
				set_virtual_text(dev_dependencies, outdated_dependencies)
				set_virtual_text(prod_dependencies, outdated_dependencies)
				set_virtual_text(peer_dependencies, outdated_dependencies)
		end)
end
