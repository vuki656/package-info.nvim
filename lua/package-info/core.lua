-- TODO: cleanup api
local json_parser

if vim.json then
    json_parser = vim.json
else
    json_parser = require("package-info.libs.json_parser")
end

local constants = require("package-info.constants")
local state = require("package-info.state")
local config = require("package-info.config")
local logger = require("package-info.logger")

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
        state.buffer.save()
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
    local buffer_raw_value = vim.api.nvim_buf_get_lines(state.buffer.id, 0, 0 - 1, false)
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
M.__get_dependency_name_from_line = function(line)
    local value = {}

    -- Tries to extract name and version
    for chunk in string.gmatch(line, [["(.-)"]]) do
        table.insert(value, chunk)
    end

    if value[1] == nil or value[2] == nil then
        return nil
    end

    local is_valid_name = M.__is_valid_dependency_name(value[1])
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
-- @param dependency_name - string package to check
M.__is_valid_dependency_name = function(dependency_name)
    if M.__dependencies[dependency_name] then
        return true
    else
        return false
    end
end

--- Gets package from current line
M.__get_dependency_name_from_current_line = function()
    local current_line = vim.fn.getline(".")

    local dependency_name = M.__get_dependency_name_from_line(current_line)
    local is_valid = M.__is_valid_dependency_name(dependency_name)

    if is_valid then
        return dependency_name
    else
        logger.error("No valid package on current line")

        return nil
    end
end

--- Clears package-info virtual text from current buffer
M.__clear_virtual_text = function()
    if state.displayed then
        vim.api.nvim_buf_clear_namespace(state.buffer.id, config.namespace, 0, -1)
    end
end

--- Reloads the buffer if it's package.json
M.__reload_buffer = function()
    local current_buffer_number = vim.fn.bufnr()

    if current_buffer_number == state.buffer.id then
        local view = vim.fn.winsaveview()
        vim.cmd(":e")
        vim.fn.winrestview(view)
    end
end

--- Rereads the current buffer value and reloads the buffer
M.__reload = function()
    M.__reload_buffer()

    M.__parse_buffer()

    if state.displayed then
        M.__clear_virtual_text()
        M.__display_virtual_text()
    end

    M.__reload_buffer()
end

--- Draws virtual text on given buffer line
-- @param outdated_dependencies - table of outdated dependancies
M.__set_virtual_text = function(outdated_dependencies, line_number, dependency_name)
    local package_metadata = {
        group = constants.HIGHLIGHT_GROUPS.up_to_date,
        icon = config.icons.style.up_to_date,
        text = M.__dependencies[dependency_name].version.current,
    }

    if state.hide_up_to_date then
        package_metadata.text = ""
        package_metadata.icon = ""
    end

    if outdated_dependencies[dependency_name] then
        if outdated_dependencies[dependency_name].latest ~= M.__dependencies[dependency_name].version.current then
            package_metadata = {
                group = constants.HIGHLIGHT_GROUPS.outdated,
                icon = config.icons.style.outdated,
                text = M.__clean_version(outdated_dependencies[dependency_name].latest),
            }
        end
    end

    if not config.icons.enable then
        package_metadata.icon = ""
    end

    vim.api.nvim_buf_set_extmark(state.buffer.id, config.namespace, line_number - 1, 0, {
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
        local dependency_name = M.__get_dependency_name_from_line(line_content)

        if dependency_name then
            M.__set_virtual_text(outdated_dependencies, line_number, dependency_name)
        end
    end

    M.__outdated_dependencies = outdated_dependencies

    state.displayed = true
end

M.load_plugin = function()
    if not M.__is_valid_package_json() then
        return
    end

    M.__parse_buffer()
end

return M
