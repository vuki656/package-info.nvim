-- DESCRIPTION: holds logic for buffer parsing and displaying virtual text

local json_parser = require("package-info.libs.json_parser")

local config = require("package-info.config")
local constants = require("package-info.constants")
local ui = require("package-info.ui")

local M = {}

--- Checks if the currently opened file is package.json and has content
M.__is_valid_package_json = function()
    local current_buffer_name = vim.api.nvim_buf_get_name(0)
    local is_package_json = string.match(current_buffer_name, "package.json$")
    local buffer_size = vim.fn.getfsize(current_buffer_name)

    return is_package_json and buffer_size > 0
end

--- Parse current buffer and return its value
M.__get_buffer_content = function()
    local buffer_raw_value = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local buffer_string_value = table.concat(buffer_raw_value)
    local buffer_json_value = json_parser.decode(buffer_string_value)

    return {
        raw = buffer_raw_value,
        string = buffer_string_value,
        json = buffer_json_value,
    }
end

--- Fetches outdated npm dependencies for the project
-- @param callback - function that will receive outdated packages in JSON format
M.__get_outdated_dependencies = function(callback)
    local value = ""

    vim.fn.jobstart("npm outdated --json", {
        on_stdout = function(_, stdout)
            value = value .. table.concat(stdout)

            if table.concat(stdout) == "" then
                local json_value = json_parser.decode(value)

                callback(json_value)
            end
        end,
    })
end

--- Gets dependencies from the package.json in JSON format
M.__get_dependencies = function()
    local buffer_content = M.__get_buffer_content()

    local dev_dependencies = buffer_content.json["devDependencies"] or {}
    local prod_dependencies = buffer_content.json["dependencies"] or {}

    return {
        prod = prod_dependencies,
        dev = dev_dependencies,
    }
end

--- Gets the package name from the given buffer line
-- @param line - string representing a buffer line
M.__get_package_name_from_line = function(line)
    return string.match(line, [["(.-)"]])
end

--- Checks if the package exists in either dev or prod dependency list
-- @param package_name - string
M.__is_valid_package = function(package_name)
    local dependencies = M.__get_dependencies()

    local is_dev_dependency = dependencies.dev[package_name]
    local is_prod_dependency = dependencies.prod[package_name]

    if is_dev_dependency or is_prod_dependency then
        return true
    end

    return false
end

--- Maps each dependency to its location in the buffer
M.__get_dependency_positions = function()
    local buffer_content = M.__get_buffer_content()

    local dependency_positions = {}

    for buffer_line_number, buffer_line_content in pairs(buffer_content.raw) do
        local package_name = M.__get_package_name_from_line(buffer_line_content)
        local is_valid = M.__is_valid_package(package_name)

        if is_valid then
            dependency_positions[package_name] = buffer_line_number - 1
        end
    end

    return dependency_positions
end

--- Gets metadata used for setting the version virtual text
-- @param current_package_version - string
-- @param outdated_dependencies - json/table
-- @param package_name - string
M.__get_package_metadata = function(current_package_version, outdated_dependencies, package_name)
    local package_metadata = {
        group = constants.HIGHLIGHT_GROUPS.up_to_date,
        icon = config.options.icons.style.up_to_date,
        version = current_package_version,
    }

    local is_outdated = outdated_dependencies[package_name]

    if is_outdated then
        package_metadata = {
            version = outdated_dependencies[package_name].latest,
            group = constants.HIGHLIGHT_GROUPS.outdated,
            icon = config.options.icons.style.outdated,
        }
    end

    if not config.options.icons.enable then
        package_metadata.icon = ""
    end

    return package_metadata
end

--- Sets virtual text for `devDependencies` and `dependencies`
-- @param dependencies - json/table from dev or prod dependencies
-- @param outdated_dependencies - outdated project dependencies in JSON format
M.__set_virtual_text = function(dependencies, outdated_dependencies)
    if not M.__is_valid_package_json() then
        return
    end

    local dependency_positions = M.__get_dependency_positions()

    for package_name, current_package_version in pairs(dependencies) do
        local package_metadata = M.__get_package_metadata(current_package_version, outdated_dependencies, package_name)

        local virtual_text = package_metadata.icon .. package_metadata.version
        local position = dependency_positions[package_name]

        vim.api.nvim_buf_set_extmark(0, config.__namespace.id, position, 0, {
            virt_text = { { virtual_text, package_metadata.group } },
            virt_text_pos = "eol",
            priority = 200,
        })
    end
end

M.show = function()
    if not M.__is_valid_package_json() then
        return
    end

    local dependencies = M.__get_dependencies()

    M.__get_outdated_dependencies(function(outdated_dependencies_json)
        M.__set_virtual_text(dependencies.dev, outdated_dependencies_json)
        M.__set_virtual_text(dependencies.prod, outdated_dependencies_json)

        config.__state.displayed = true
    end)
end

M.hide = function()
    vim.api.nvim_buf_clear_namespace(0, config.__namespace.id, 0, -1)

    config.__state.displayed = false
end

M.delete = function()
    local current_line = vim.fn.getline(".")

    local package_name = M.__get_package_name_from_line(current_line)
    local is_valid = M.__is_valid_package(package_name)

    if not is_valid then
        vim.api.nvim_echo({ { "No package under current line.", "WarningMsg" } }, {}, {})
    else
        ui.display_menu({
            command = "yarn remove " .. package_name,
            title = " Delete [" .. package_name .. "] Package ",
            callback = function()
                vim.api.nvim_echo({ { package_name .. " deleted successfully" } }, {}, {})
                vim.cmd(":e")

                if config.__state.displayed then
                    M.hide()
                    M.show()
                end
            end,
        })
    end
end

M.update = function()
    local current_line = vim.fn.getline(".")

    local package_name = M.__get_package_name_from_line(current_line)
    local is_valid = M.__is_valid_package(package_name)

    if not is_valid then
        vim.api.nvim_echo({ { "No package under current line.", "WarningMsg" } }, {}, {})
    else
        ui.display_menu({
            command = "yarn upgrade --latest " .. package_name,
            title = " Update [" .. package_name .. "] Package ",
            callback = function()
                vim.api.nvim_echo({ { package_name .. " updated successfully" } }, {}, {})
                vim.cmd(":e")

                if config.__state.displayed then
                    M.hide()
                    M.show()
                end
            end,
        })
    end
end

return M
