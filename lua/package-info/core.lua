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

local M = {
    -- All found dependancies from package.json as a list of
    -- ["dependency_name"] = {
    --     version = {
    --         current: string - current package version,
    --         latest: string - latest package version,
    --     },
    -- }
    __dependencies = {},
    -- JSON output from npm outdated --json
    __outdated_dependencies = {},
    -- String value of buffer from vim.api.nvim_buf_get_lines(state.buffer.id, 0, 0 - 1, false)
    __buffer = {},
}

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

--- Try and decode json from string and panic if invalid
-- @param value: string - json string to try and decode
-- @return json?: table - converted json value
M.__decode_json_string = function(value)
    local function decode()
        json_parser.decode(value)
    end

    if pcall(decode) then
        return json_parser.decode(value)
    else
        logger.error("Invalid JSON format in package.json")

        return nil
    end
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
-- @param outdated_dependencies: table - outdated dependancies
-- {
--     [dependency_name]: {
--         current: string - currently installed version
--         latest: string - latest available version
--     }
-- }
-- @param line_number: number - line on which to place virtual text
-- @param dependency_name: string - dependency based on which to get the virtual text
-- @return nil
M.__set_virtual_text = function(outdated_dependencies, line_number, dependency_name)
    local package_metadata = {
        group = constants.HIGHLIGHT_GROUPS.up_to_date,
        icon = config.options.icons.style.up_to_date,
        version = M.__dependencies[dependency_name].version.current,
    }

    if config.options.hide_up_to_date then
        package_metadata.version = ""
        package_metadata.icon = ""
    end

    if outdated_dependencies[dependency_name] then
        if outdated_dependencies[dependency_name].latest ~= M.__dependencies[dependency_name].version.current then
            package_metadata = {
                group = constants.HIGHLIGHT_GROUPS.outdated,
                icon = config.options.icons.style.outdated,
                version = M.__clean_version(outdated_dependencies[dependency_name].latest),
            }
        end
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
    M.__reload_buffer()

    M.parse_buffer()

    if state.displayed then
        M.clear_virtual_text()
        M.display_virtual_text()
    end

    M.__reload_buffer()
end

--- Handles virtual text displaying
-- @param outdated_dependencies?: table - outdated dependancies
-- {
--     [dependency_name]: {
--         current: string - currently installed version
--         latest: string - latest available version
--     }
-- }
-- @return nil
M.display_virtual_text = function(outdated_dependencies)
    outdated_dependencies = outdated_dependencies or M.__outdated_dependencies

    for line_number, line_content in ipairs(M.__buffer) do
        local dependency_name = M.get_dependency_name_from_line(line_content)

        if dependency_name then
            M.__set_virtual_text(outdated_dependencies, line_number, dependency_name)
        end
    end

    M.__outdated_dependencies = outdated_dependencies

    state.displayed = true
end

--- Checks if the currently opened file is package.json and has content
-- @return boolean
M.is_valid_package_json = function()
    local current_buffer_name = vim.api.nvim_buf_get_name(0)
    local is_package_json = string.match(current_buffer_name, "package.json$")
    local buffer_size = vim.fn.getfsize(current_buffer_name)

    local is_valid = is_package_json and buffer_size > 0

    if is_valid then
        state.buffer.save()
    end

    return is_valid
end

--- Loads current buffer into state
-- @return nil
M.parse_buffer = function()
    local buffer_raw_value = vim.api.nvim_buf_get_lines(state.buffer.id, 0, 0 - 1, false)
    local buffer_string_value = table.concat(buffer_raw_value)
    local buffer_json_value = M.__decode_json_string(buffer_string_value)

    if buffer_json_value == nil then
        return nil
    end

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
        }
    end

    M.__buffer = buffer_raw_value
    M.__dependencies = dependencies
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

    local is_valid_name = M.__dependencies[value[1]]
    local is_valid_version = M.__is_valid_package_version(value[2])

    if is_valid_name and is_valid_version then
        return value[1]
    else
        return nil
    end
end

--- Parser current buffer if valid
-- @return nil
M.load_plugin = function()
    if not M.is_valid_package_json() then
        return nil
    end

    M.parse_buffer()
end

return M
