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

local constants = require("package-info.utils.constants")
local state = require("package-info.state")
local config = require("package-info.config")
local logger = require("package-info.utils.logger")
local to_boolean = require("package-info.utils.to-boolean")

local M = {
    -- All found dependencies from package.json as a list of
    -- ["dependency_name"] = {
    --     version = {
    --         current: string - current package version,
    --         latest: string - latest package version,
    --     },
    -- }
    __dependencies = {},
    -- String value of buffer from vim.api.nvim_buf_get_lines(state.buffer.id, 0, -1, false)
    __buffer_lines = {},
    -- JSON output from npm outdated --json
    outdated_dependencies = {},
}

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

--- Strips ^ from version
-- @param value: string - value from which to strip ^ from
-- @return string
M.__clean_version = function(value)
    if value == nil then
        return nil
    end

    return value:gsub("%^", "")
end

--- Checks if the given string conforms to 1.0.0 version format
-- @param value: string - value to check if conforms
-- @return boolean
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
-- @param outdated_dependencies: table - outdated dependencies
-- {
--     [dependency_name]: {
--         current: string - currently installed version
--         latest: string - latest available version
--     }
-- }
-- @param line_number: number - line on which to place virtual text
-- @param dependency_name: string - dependency based on which to get the virtual text
-- @return nil
M.__set_virtual_text = function(line_number, dependency_name)
    local package_metadata = {
        group = constants.HIGHLIGHT_GROUPS.up_to_date,
        icon = config.options.icons.style.up_to_date,
        version = M.__dependencies[dependency_name].version.current,
    }

    if config.options.hide_up_to_date then
        package_metadata.version = ""
        package_metadata.icon = ""
    end

    local outdated_dependency = M.outdated_dependencies[dependency_name]

    if not outdated_dependency then
        return nil
    end

    if outdated_dependency.latest ~= M.__dependencies[dependency_name].version.current then
        package_metadata = {
            group = constants.HIGHLIGHT_GROUPS.outdated,
            icon = config.options.icons.style.outdated,
            version = M.__clean_version(outdated_dependency.latest),
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

    if M.__dependencies[dependency_name] then
        return dependency_name
    else
        logger.warn("No valid package on current line")

        return nil
    end
end

--- Rereads the current buffer value and reloads the buffer
-- @return nil
M.reload = function()
    if not state.loaded then
        return
    end

    M.__reload_buffer()

    M.parse_buffer()

    if state.displayed then
        M.clear_virtual_text()
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
    for line_number, line_content in ipairs(M.__buffer_lines) do
        local dependency_name = M.get_dependency_name_from_line(line_content)

        if dependency_name then
            M.__set_virtual_text(line_number, dependency_name)
        end
    end

    state.displayed = true
end

--- Loads current buffer into state
-- @return nil
M.parse_buffer = function()
    local buffer_lines = vim.api.nvim_buf_get_lines(state.buffer.id, 0, -1, false)
    local buffer_json_value = json_parser.decode(table.concat(buffer_lines))

    local all_dependencies_json = vim.tbl_extend(
        "error",
        {},
        buffer_json_value["devDependencies"],
        buffer_json_value["dependencies"]
    )

    local formatted_dependencies = {}

    for name, version in pairs(all_dependencies_json) do
        formatted_dependencies[name] = {
            version = {
                current = M.__clean_version(version),
            },
        }
    end

    M.__buffer_lines = buffer_lines
    M.__dependencies = formatted_dependencies
end

--- Clears plugin virtual text from current buffer
-- @return nil
M.clear_virtual_text = function()
    if state.displayed then
        vim.api.nvim_buf_clear_namespace(state.buffer.id, state.namespace.id, 0, -1)
    end
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
    if value[1] == nil or value[2] == nil then
        return nil
    end

    local is_valid_name = to_boolean(M.__dependencies[value[1]])
    local is_valid_version = M.__is_valid_package_version(value[2])

    if is_valid_name and is_valid_version then
        return value[1]
    end

    return nil
end

--- Parser current buffer if valid
-- @return nil
M.load_plugin = function()
    if not M.__is_valid_package_json() then
        state.loaded = false

        return nil
    end

    state.buffer.save()
    state.loaded = true

    M.parse_buffer()
end

return M
