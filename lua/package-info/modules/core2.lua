local json_parser = require("package-info.libs.json_parser")

local constants = require("package-info.constants")
local config = require("package-info.config")
local utils = require("package-info.utils")
local ui = require("package-info.ui")

local M = {}

------------------------------------------------------------------------------
----------------------------- PRIVATE ----------------------------------------
------------------------------------------------------------------------------

--- Checks if the currently opened file is package.json and has content
M.__is_valid_package_json = function()
    local current_buffer_name = vim.api.nvim_buf_get_name(0)
    local is_package_json = string.match(current_buffer_name, "package.json$")
    local buffer_size = vim.fn.getfsize(current_buffer_name)

    return is_package_json and buffer_size > 0
end

--- Gets the package name from the given buffer line
-- @param line - string representing a buffer line
M.__get_package_name_from_line = function(line)
    return string.match(line, [["(.-)"]])
end

--- Gets the package version from the given buffer line
-- Expects '"name": "2.3.4"', and gets the second match for value in between parentheses
-- @param line - string representing a buffer line
M.__get_package_version_from_line = function(line)
    local value = {}

    for chunk in string.gmatch(line, [["(.-)"]]) do
        table.insert(value, chunk)
    end

    return value[2]:gsub("%^", "")
end

--- Checks if the package exists in dependency list
-- @param package_name - string
M.__is_valid_package = function(package_name)
    if package_name == nil then
        return false
    end

    if M.metadata[package_name] then
        return true
    end

    return false
end

--- Gets package from current line and validates it
M.__get_package_and_validate = function()
    local current_line = vim.fn.getline(".")

    local package_name = M.__get_package_name_from_line(current_line)
    local is_valid = M.__is_valid_package(package_name)

    if is_valid then
        return package_name
    else
        return nil
    end
end

--- Gets buffer raw, json and dependency list values
M.__get_buffer_content = function()
    local buffer_raw_value = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local buffer_string_value = table.concat(buffer_raw_value)
    local buffer_json_value = json_parser.decode(buffer_string_value)

    local dev_dependencies = buffer_json_value["devDependencies"] or {}
    local prod_dependencies = buffer_json_value["dependencies"] or {}
    local all_dependencies = vim.tbl_extend("error", {}, dev_dependencies, prod_dependencies)

    local metadata = {}

    for dependency_name, dependency_version in pairs(all_dependencies) do
        metadata[dependency_name] = {
            version = {
                current = dependency_version,
            },
        }
    end

    return {
        raw = buffer_raw_value,
        json = buffer_json_value,
        dependencies = metadata,
    }
end

--- Gets outdated dependency json
-- @param callback - function to invoke after
M.__get_outdated_dependencies = function(callback)
    job({
        json = true,
        command = "npm outdated --json",
        callback = callback,
    })
end

--- Clears package-info virtual text from current buffer
M.__clear_virtual_text = function()
    vim.api.nvim_buf_clear_namespace(0, config.namespace.id, 0, -1)
end

--- Takes new buffer value and updates metadata
M.__update_metadata = function()
    local buffer_content = M.__get_buffer_content()

    for buffer_line_number, buffer_line_content in ipairs(buffer_content.raw) do
        local package_name = M.__get_package_name_from_line(buffer_line_content)
        local package = buffer_content.dependencies[package_name]

        if package then
            local current_package_version = M.__get_package_version_from_line(buffer_line_content)

            M.metadata[package_name].version.current = current_package_version
            M.metadata[package_name].position = buffer_line_number
        end
    end
end

--- Display virtual text based on current state
M.__display_virtual_text = function()
    local buffer_content = M.__get_buffer_content()

    for buffer_line_number, buffer_line_content in ipairs(buffer_content.raw) do
        local package_name = M.__get_package_name_from_line(buffer_line_content)
        local package = buffer_content.dependencies[package_name]

        if package then
            local cached_package = M.metadata[package_name]

            local current_version = cached_package.version.current
            local latest_version = cached_package.version.latest:gsub("%^", "")

            local package_metadata = {
                group = constants.HIGHLIGHT_GROUPS.up_to_date,
                icon = config.options.icons.style.up_to_date,
                text = current_version,
            }

            if current_version ~= latest_version then
                package_metadata = {
                    text = latest_version,
                    group = constants.HIGHLIGHT_GROUPS.outdated,
                    icon = config.options.icons.style.outdated,
                }
            end

            local virtual_text = package_metadata.icon .. package_metadata.text

            if not config.options.icons.enable then
                package_metadata.icon = ""
            end

            vim.api.nvim_buf_set_extmark(0, config.namespace.id, buffer_line_number - 1, 0, {
                virt_text = { { virtual_text, package_metadata.group } },
                virt_text_pos = "eol",
                priority = 200,
            })
        end
    end

    utils.loading.stop()
    config.state.displayed = true
end

--- Clears and sets up to date virtual text
M.__reload = function()
    vim.cmd(":e")

    M.__clear_virtual_text()
    M.__update_metadata()
    M.__display_virtual_text()

    vim.cmd(":e")
end

------------------------------------------------------------------------------
----------------------------- PUBLIC -----------------------------------------
------------------------------------------------------------------------------

M.show = function()
    if not M.__is_valid_package_json() then
        return
    end

    utils.loading.start("|  Fetching latest versions")

    M.__get_outdated_dependencies(function(outdated_dependencies)
        local buffer_content = M.__get_buffer_content()

        local metadata = {}

        M.__clear_virtual_text()

        for buffer_line_number, buffer_line_content in ipairs(buffer_content.raw) do
            local package_name = M.__get_package_name_from_line(buffer_line_content)
            local package = buffer_content.dependencies[package_name]

            if package then
                local package_metadata = {
                    group = constants.HIGHLIGHT_GROUPS.up_to_date,
                    icon = config.options.icons.style.up_to_date,
                    text = package.version.current:gsub("%^", ""),
                }

                if config.options.hide_up_to_date then
                    package_metadata.text = ""
                    package_metadata.icon = ""
                end

                if outdated_dependencies[package_name] then
                    package_metadata = {
                        text = outdated_dependencies[package_name].latest:gsub("%^", ""),
                        group = constants.HIGHLIGHT_GROUPS.outdated,
                        icon = config.options.icons.style.outdated,
                    }
                end

                if not config.options.icons.enable then
                    package_metadata.icon = ""
                end

                vim.api.nvim_buf_set_extmark(0, config.namespace.id, buffer_line_number - 1, 0, {
                    virt_text = { { package_metadata.icon .. package_metadata.text, package_metadata.group } },
                    virt_text_pos = "eol",
                    priority = 200,
                })

                metadata[package_name] = {
                    version = {
                        current = buffer_content.dependencies[package_name].version,
                        latest = package_metadata.text,
                    },
                    position = buffer_line_number,
                }
            end
        end

        utils.loading.stop()
        config.state.displayed = true

        M.metadata = metadata
    end)
end

M.hide = function()
    M.__clear_virtual_text()

    config.state.displayed = false
end

M.delete = function()
    local package_name = M.__get_package_and_validate()

    if package_name then
        utils.loading.start("|  Deleting " .. package_name .. " package")

        ui.display_prompt({
            command = config.get_command.delete(package_name),
            title = " Delete [" .. package_name .. "] Package ",
            on_submit = function()
                M.__reload()

                utils.loading.stop()
            end,
            on_cancel = function()
                utils.loading.stop()
            end,
        })
    end
end

M.update = function()
    local package_name = M.__get_package_and_validate()

    if package_name then
        utils.loading.start("| ﯁ Updating " .. package_name .. " package")

        ui.display_prompt({
            command = config.get_command.update(package_name),
            title = " Update [" .. package_name .. "] Package ",
            on_submit = function()
                M.__reload()

                utils.loading.stop()
            end,
            on_cancel = function()
                utils.loading.stop()
            end,
        })
    end
end

return M
