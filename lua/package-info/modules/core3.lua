local Menu = require("nui.menu")

local json_parser = require("package-info.libs.json_parser")

local constants = require("package-info.constants")
local config = require("package-info.config")
local utils = require("package-info.utils")
local ui = require("package-info.ui")
local logger = require("package-info.logger")

local M = {
    __dependencies = {},
    __outdated_dependencies = {},
    __buffer = {},
}

--- Gets outdated dependency json
-- @param callback - function to invoke after
M.__get_outdated_dependencies = function(callback)
    utils.job({
        json = true,
        command = utils.get_command.outdated(),
        on_success = callback,
    })
end

--- Checks if the currently opened file is package.json and has content
M.__is_valid_package_json = function()
    local current_buffer_name = vim.api.nvim_buf_get_name(0)
    local is_package_json = string.match(current_buffer_name, "package.json$")
    local buffer_size = vim.fn.getfsize(current_buffer_name)

    local is_valid = is_package_json and buffer_size > 0

    if is_valid then
        config.state.store_buffer_id()
    end

    return is_valid
end

--- Strips ^ from version
M.__clean_version = function(string)
    return string:gsub("%^", "")
end

--- Loads current buffer into state
M.__parse_buffer = function()
    local buffer_raw_value = vim.api.nvim_buf_get_lines(config.state.buffer_id, 0, 0 - 1, false)
    local buffer_string_value = table.concat(buffer_raw_value)
    local buffer_json_value = json_parser.decode(buffer_string_value)

    local dev_dependencies = buffer_json_value["devDependencies"] or {}
    local prod_dependencies = buffer_json_value["dependencies"] or {}
    local all_dependencies = vim.tbl_extend("error", {}, dev_dependencies, prod_dependencies)

    local dependencies = {}

    for name, version in pairs(all_dependencies) do
        dependencies[name] = {
            version = {
                current = M.__clean_version(version),
                latest = nil,
            },
            position = nil,
        }
    end

    M.__buffer = buffer_raw_value
    M.__dependencies = dependencies
end

--- Gets the package name from the given buffer line
-- @param line - string representing a buffer line
M.__get_package_name_from_line = function(line)
    local package_name = string.match(line, [["(.-)"]])
    local is_valid = M.__is_valid_package_name(package_name)

    if is_valid then
        return package_name
    else
        return nil
    end
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

--- Verifies that the given package is on the package list
-- @param package_name - string package to check
M.__is_valid_package_name = function(package_name)
    if M.__dependencies[package_name] then
        return true
    else
        return false
    end
end

--- Gets package from current line
M.__get_package_name_from_current_line = function()
    local current_line = vim.fn.getline(".")

    local package_name = M.__get_package_name_from_line(current_line)
    local is_valid = M.__is_valid_package_name(package_name)

    if is_valid then
        return package_name
    else
        logger.error("No valid package on current line")

        return nil
    end
end

--- Clears package-info virtual text from current buffer
M.__clear_virtual_text = function()
    if config.state.displayed then
        vim.api.nvim_buf_clear_namespace(config.state.buffer_id, config.namespace.id, 0, -1)
    end
end

--- Rereads the current buffer value and reloads the buffer
M.__reload = function()
    vim.cmd(":e")

    M.__parse_buffer()

    if config.state.displayed then
        M.__clear_virtual_text()
        M.__display_virtual_text()
    end

    vim.cmd(":e")
end

--- Draws virtual text on given buffer line
-- @param outdated_dependencies - table of outdated dependancies
M.__set_virtual_text = function(outdated_dependencies, line_number, package_name)
    local package_metadata = {
        group = constants.HIGHLIGHT_GROUPS.up_to_date,
        icon = config.options.icons.style.up_to_date,
        text = M.__dependencies[package_name].version.current,
    }

    if config.options.hide_up_to_date then
        package_metadata.text = ""
        package_metadata.icon = ""
    end

    if outdated_dependencies[package_name] then
        if outdated_dependencies[package_name].latest ~= M.__dependencies[package_name].version.current then
            package_metadata = {
                group = constants.HIGHLIGHT_GROUPS.outdated,
                icon = config.options.icons.style.outdated,
                text = M.__clean_version(outdated_dependencies[package_name].latest),
            }
        end
    end

    if not config.options.icons.enable then
        package_metadata.icon = ""
    end

    vim.api.nvim_buf_set_extmark(config.state.buffer_id, config.namespace.id, line_number - 1, 0, {
        virt_text = { { package_metadata.icon .. package_metadata.text, package_metadata.group } },
        virt_text_pos = "eol",
        priority = 200,
    })
end

--- Handles virtual text displaying
-- @param outdated_dependencies - table of outdated dependancies
M.__display_virtual_text = function(outdated_dependencies)
    outdated_dependencies = outdated_dependencies or M.__outdated_dependencies

    for line_number, line_content in ipairs(M.__buffer) do
        local package_name = M.__get_package_name_from_line(line_content)

        if package_name then
            M.__set_virtual_text(outdated_dependencies, line_number, package_name)
        end
    end

    M.__outdated_dependencies = outdated_dependencies
end

M.load_plugin = function()
    if not M.__is_valid_package_json() then
        return
    end

    M.__parse_buffer()
end

M.show = function(options)
    options = options or { force = false }

    if config.state.should_skip() and options.force == false then
        M.__display_virtual_text()
        M.__reload()

        return
    end

    utils.loading.start("|  Fetching latest versions")

    M.__get_outdated_dependencies(function(outdated_dependencies)
        M.__parse_buffer()
        M.__display_virtual_text(outdated_dependencies)
        M.__reload()

        utils.loading.stop()

        config.state.update_last_run()
        config.state.displayed = true
    end)
end

M.delete = function()
    local package_name = M.__get_package_name_from_current_line()

    if package_name then
        utils.loading.start("|  Deleting " .. package_name .. " package")

        ui.display_prompt({
            command = utils.get_command.delete(package_name),
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
    local package_name = M.__get_package_name_from_current_line()

    if package_name then
        utils.loading.start("| ﯁ Updating " .. package_name .. " package")

        ui.display_prompt({
            command = utils.get_command.update(package_name),
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

M.install = function()
    ui.display_install_menu(function(dependency_type)
        ui.display_install_input(function(dependency_name)
            if dependency_name == "" then
                logger.error("No package specified")

                return
            end

            utils.loading.start("|  Installing " .. dependency_name .. " package")

            utils.job({
                command = utils.get_command.install(dependency_type, dependency_name),
                on_success = function()
                    M.__reload()

                    utils.loading.stop()
                end,
                on_error = function()
                    utils.loading.stop()
                end,
            })
        end)
    end)
end

M.reinstall = function()
    utils.loading.start("| ﰇ Reinstalling dependencies")

    utils.job({
        json = false,
        command = utils.get_command.reinstall(),
        on_success = function()
            M.__reload()

            utils.loading.stop()
        end,
        on_error = function()
            utils.loading.stop()
        end,
    })
end

M.change_version = function()
    local package_name = M.__get_package_name_from_current_line()

    if package_name then
        utils.loading.start("|  Fetching " .. package_name .. " versions")

        utils.job({
            json = true,
            command = utils.get_command.version_list(package_name),
            on_success = function(versions)
                utils.loading.stop()

                local menu_items = {}

                -- Iterate versions from the end to show the latest versions first
                for index = #versions, 1, -1 do
                    local version = versions[index]

                    --  Skip unstable version e.g next@11.1.0-canary
                    if not config.options.hide_unstable_versions and not string.match(version, "-") then
                        table.insert(menu_items, Menu.item(version))
                    end
                end

                ui.display_change_version_menu({
                    package_name = package_name,
                    menu_items = menu_items,
                    on_success = function()
                        M.__reload()
                    end,
                })
            end,
            on_error = function()
                utils.loading.stop()
            end,
        })
    end
end

M.hide = function()
    M.__clear_virtual_text()

    config.state.displayed = false
end

return M
