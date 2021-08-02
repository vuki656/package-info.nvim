local json_parser = require("package-info.libs.json_parser")

local Module = {}

Module.parse_package_json = function()
    local CURRENT_BUFFER = 0
    local BUFFER_START_INDEX = 0
    local BUFFER_END_INDEX = -1

    -- Get current buffer content
    local buffer_content = vim.api.nvim_buf_get_lines(CURRENT_BUFFER, BUFFER_START_INDEX, BUFFER_END_INDEX, false)

    -- Convert buffer content to string (JSON)
    local string_value = table.concat(buffer_content)

    -- Convert JSON to table
    local json_value = json_parser.decode(string_value)

    return json_value
end

return Module
