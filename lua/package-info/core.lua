-- TODO: if you have invalid json, then fix it, plugin still wont run
-- TODO: action tests

local json_parser = require("package-info.libs.json_parser")
local parser = require("package-info.parser")
local constants = require("package-info.utils.constants")
local state = require("package-info.state")
local config = require("package-info.config")
local to_boolean = require("package-info.utils.to-boolean")
local clean_version = require("package-info.helpers.clean_version")
local get_dependency_name_from_line = require("package-info.helpers.get_dependency_name_from_line")

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

--- Draws virtual text on given buffer line
-- @param line_number: number - line on which to place virtual text
-- @param dependency_name: string - dependency based on which to get the virtual text
-- @return nil
M.__set_virtual_text = function(line_number, dependency_name)
    local virtual_text = {
        group = constants.HIGHLIGHT_GROUPS.up_to_date,
        icon = config.options.icons.style.up_to_date,
        version = state.dependencies.installed[dependency_name].current,
    }

    if config.options.hide_up_to_date then
        virtual_text.version = ""
        virtual_text.icon = ""
    end

    local outdated_dependency = state.dependencies.outdated[dependency_name]

    if outdated_dependency and outdated_dependency.latest ~= state.dependencies.installed[dependency_name].current then
        virtual_text = {
            group = constants.HIGHLIGHT_GROUPS.outdated,
            icon = config.options.icons.style.outdated,
            version = clean_version(outdated_dependency.latest),
        }
    end

    if not config.options.icons.enable then
        virtual_text.icon = ""
    end

    vim.api.nvim_buf_set_extmark(state.buffer.id, state.namespace.id, line_number - 1, 0, {
        virt_text = { { virtual_text.icon .. virtual_text.version, virtual_text.group } },
        virt_text_pos = "eol",
        priority = 200,
    })

    -- NOTE: used for testing only since there's no way to get virtual text content via nvim API
    return virtual_text
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
        local dependency_name = get_dependency_name_from_line(line_content)

        if dependency_name then
            M.__set_virtual_text(line_number, dependency_name)
        end
    end

    state.virtual_text.is_displayed = true
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
