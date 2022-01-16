-- TODO: make sure all functions are atomic if possible
-- TODO: consider moving stuff out of the core that's not coupled with it
-- TODO: if you have invalid json, then fix it, plugin still wont run
-- TODO: action tests

local json_parser

if vim.json then
    json_parser = vim.json
else
    json_parser = require("package-info.libs.json_parser")
end

local parser = require("package-info.parser")
local constants = require("package-info.utils.constants")
local state = require("package-info.state")
local config = require("package-info.config")
local logger = require("package-info.utils.logger")
local to_boolean = require("package-info.utils.to-boolean")
local clean_version = require("package-info.helpers.clean_version")

local M = {}

--- Checks if the currently opened file
---    - Is a file named package.json
---    - Has content
---    - JSON is in valid format
-- @return boolean
M.__is_valid_package_json = function()
    local buffer_name = vim.api.nvim_buf_get_name(0)
    local is_package_json = to_boolean(string.match(buffer_name, "package.json$"))

    if not is_package_json then
        return false
    end

    local has_content = to_boolean(vim.api.nvim_buf_get_lines(0, 0, -1, false))

    if not has_content then
        return false
    end

    local buffer_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    if pcall(function()
        json_parser.decode(table.concat(buffer_content))
    end) then
        return true
    end

    return false
end

--- Checks if the given string conforms to 1.0.0 version format
-- @param value: string - value to check if conforms
-- @return boolean
M.__is_valid_package_version = function(value)
    local cleaned_version = clean_version(value)

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

--- Reloads the buffer if it's package.json
-- @return nil
M.__reload_buffer = function()
    local current_buffer_number = vim.fn.bufnr()

    if current_buffer_number == state.buffer.id then
        local view = vim.fn.winsaveview()

        vim.cmd("edit")
        vim.fn.winrestview(view)
    end
end

--- Draws virtual text on given buffer line
-- @param line_number: number - line on which to place virtual text
-- @param dependency_name: string - dependency based on which to get the virtual text
-- @return nil
M.__set_virtual_text = function(line_number, dependency_name)
    local package_metadata = {
        group = constants.HIGHLIGHT_GROUPS.up_to_date,
        icon = config.options.icons.style.up_to_date,
        version = state.dependencies.installed[dependency_name].current,
    }

    if config.options.hide_up_to_date then
        package_metadata.version = ""
        package_metadata.icon = ""
    end

    local outdated_dependency = state.dependencies.outdated[dependency_name]

    if outdated_dependency and outdated_dependency.latest ~= state.dependencies.installed[dependency_name].current then
        package_metadata = {
            group = constants.HIGHLIGHT_GROUPS.outdated,
            icon = config.options.icons.style.outdated,
            version = clean_version(outdated_dependency.latest),
        }
    end

    if not config.options.icons.enable then
        package_metadata.icon = ""
    end

    vim.api.nvim_buf_set_extmark(state.buffer.id, state.namespace.id, line_number - 1, 0, {
        virt_text = { { package_metadata.icon .. package_metadata.version, package_metadata.group } },
        virt_text_pos = "eol",
        priority = 200,
    })

    -- NOTE: used for testing only since there's not way to get virtual text content via nvim API
    return package_metadata
end

--- Gets package from current line
-- @return string?
M.get_dependency_name_from_current_line = function()
    local current_line = vim.fn.getline(".")

    local dependency_name = M.get_dependency_name_from_line(current_line)

    if state.dependencies.installed[dependency_name] then
        return dependency_name
    else
        logger.warn("No valid package on current line")

        return nil
    end
end

--- Rereads the current buffer value and reloads the buffer
-- @return nil
M.reload = function()
    if not state.is_loaded then
        return
    end

    M.__reload_buffer()

    parser.parse_buffer()

    if state.virtual_text.is_displayed then
        state.virtual_text.clear()
        M.display_virtual_text()
    end

    M.__reload_buffer()
end

--- Handles virtual text displaying
-- @param outdated_dependencies?: table - outdated dependencies
-- {
--     [dependency_name]: {
--         current: string - currently installed version
--         latest: string - latest available version
--     }
-- }
-- @return nil
M.display_virtual_text = function()
    for line_number, line_content in ipairs(state.buffer.lines) do
        local dependency_name = M.get_dependency_name_from_line(line_content)

        if dependency_name then
            M.__set_virtual_text(line_number, dependency_name)
        end
    end

    state.virtual_text.is_displayed = true
end

--- Gets the package name from the given buffer line
-- @param line: string - buffer line from which to get the name from
-- @return string?
M.get_dependency_name_from_line = function(line)
    local value = {}

    -- Tries to extract name and version
    for chunk in string.gmatch(line, [["(.-)"]]) do
        table.insert(value, chunk)
    end

    -- If no version or name fail
    if not value[1] or not value[2] then
        return nil
    end

    local is_installed = to_boolean(state.dependencies.installed[value[1]])
    local is_valid_version = M.__is_valid_package_version(value[2])

    if is_installed and is_valid_version then
        return value[1]
    end

    return nil
end

--- Parser current buffer if valid
-- @return nil
M.load_plugin = function()
    if not M.__is_valid_package_json() then
        state.is_loaded = false

        return nil
    end

    state.buffer.save()
    state.is_loaded = true

    parser.parse_buffer()
end

return M
