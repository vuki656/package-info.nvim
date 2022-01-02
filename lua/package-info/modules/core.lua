-- TODO : extract each command call to separate file

local Menu = require("nui.menu")

local json_parser
if vim.json then
    json_parser = vim.json
else
    json_parser = require("package-info.libs.json_parser")
end

local constants = require("package-info.constants")
local config = require("package-info.config")
local utils = require("package-info.utils")
local ui = require("package-info.ui")
local logger = require("package-info.logger")

local Prompt = require("package-info.ui.generic.prompt")

local M = {
    __dependencies = {},
    __outdated_dependencies = {},
    __buffer = {},
}

--- Checks if the currently opened file is package.json and has content
M.__is_valid_package_json = function()
    local current_buffer_name = vim.api.nvim_buf_get_name(0)
    local is_package_json = string.match(current_buffer_name, "package.json$")
    local buffer_size = vim.fn.getfsize(current_buffer_name)

    local is_valid = is_package_json and buffer_size > 0

    if is_valid then
        config.state.buffer.save()
    end

    return is_valid
end

--- Strips ^ from version
M.__clean_version = function(string)
    if string == nil then
        return nil
    end

    return string:gsub("%^", "")
end

--- Loads current buffer into state
M.__parse_buffer = function()
    local buffer_raw_value = vim.api.nvim_buf_get_lines(config.state.buffer.id, 0, 0 - 1, false)
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

--- Checks if the given string conforms to 1.0.0 version format
-- @param value - string to check
M.__is_valid_package_version = function(value)
    local cleaned_version = M.__clean_version(value)

    if cleaned_version == nil then
        return false
    end

    local position = 0
    local is_valid = true

    -- Check that the first two chunks in version string are numbers
    -- Everything beyond could be unstable version suffix
    for chunk in string.gmatch(cleaned_version, "([^.]+)") do
        if position ~= 2 and type(tonumber(chunk)) ~= "number" then
            is_valid = false
        end

        position = position + 1
    end

    return is_valid
end

--- Gets the package name from the given buffer line
-- @param line - string representing a buffer line
M.__get_package_name_from_line = function(line)
    local value = {}

    -- Tries to extract name and version
    for chunk in string.gmatch(line, [["(.-)"]]) do
        table.insert(value, chunk)
    end

    if value[1] == nil or value[2] == nil then
        return nil
    end

    local is_valid_name = M.__is_valid_package_name(value[1])
    local is_valid_version = M.__is_valid_package_version(value[2])

    if is_valid_name and is_valid_version then
        return value[1]
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
        vim.api.nvim_buf_clear_namespace(config.state.buffer.id, config.namespace.id, 0, -1)
    end
end

--- Reloads the buffer if it's package.json
M.__reload_buffer = function()
    local current_buffer_number = vim.fn.bufnr()

    if current_buffer_number == config.state.buffer.id then
        local view = vim.fn.winsaveview()
        vim.cmd(":e")
        vim.fn.winrestview(view)
    end
end

--- Rereads the current buffer value and reloads the buffer
M.__reload = function()
    M.__reload_buffer()

    M.__parse_buffer()

    if config.state.displayed then
        M.__clear_virtual_text()
        M.__display_virtual_text()
    end

    M.__reload_buffer()
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

    vim.api.nvim_buf_set_extmark(config.state.buffer.id, config.namespace.id, line_number - 1, 0, {
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

    config.state.displayed = true
end

M.load_plugin = function()
    if not M.__is_valid_package_json() then
        return
    end

    M.__parse_buffer()
end

M.show = function(options)
    if not M.__is_valid_package_json() then
        return
    end

    options = options or { force = false }

    if config.state.last_run.should_skip() and options.force == false then
        M.__display_virtual_text()
        M.__reload()

        return
    end

    utils.loading.start("|  Fetching latest versions")

    utils.job({
        json = true,
        command = utils.get_command.outdated(),
        ignore_error = true,
        on_success = function(outdated_dependencies)
            M.__parse_buffer()
            M.__display_virtual_text(outdated_dependencies)
            M.__reload()

            utils.loading.stop()

            config.state.last_run.update()
        end,
        on_error = function()
            utils.loading.stop()
        end,
    })
end

M.delete = function()
    local package_name = M.__get_package_name_from_current_line()

    if package_name then
        utils.loading.start("|  Deleting " .. package_name .. " package")

        Prompt.New({
            command = utils.get_command.delete(package_name),
            title = " Delete [" .. package_name .. "] Package ",
            on_submit = function()
                M.__reload()

                utils.loading.stop()
            end,
            on_cancel = function()
                utils.loading.stop()
            end,
            on_error = function()
                M.__reload()

                utils.loading.stop()
            end,
        })

        Prompt.Open({
            on_error = function()
                utils.loading.stop()
            end,
        })
    end
end

M.update = function()
    local package_name = M.__get_package_name_from_current_line()

    if package_name then
        utils.loading.start("| ﯁ Updating " .. package_name .. " package")

        Prompt.New({
            command = utils.get_command.update(package_name),
            title = " Update [" .. package_name .. "] Package ",
            on_submit = function()
                M.__reload()

                utils.loading.stop()
            end,
            on_cancel = function()
                utils.loading.stop()
            end,
            on_error = function()
                M.__reload()

                utils.loading.stop()
            end,
        })

        Prompt.Open({
            on_error = function()
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
                    if config.options.hide_unstable_versions and string.match(version, "-") then
                    else
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
