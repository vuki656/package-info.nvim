local json_parser

if vim.json then
    json_parser = vim.json
else
    json_parser = require("package-info.libs.json_parser")
end

local state = require("package-info.state")
local clean_version = require("package-info.helpers.clean_version")

local M = {}

M.parse_buffer = function()
    local buffer_lines = vim.api.nvim_buf_get_lines(state.buffer.id, 0, -1, false)
    local buffer_json_value = json_parser.decode(table.concat(buffer_lines))

    local all_dependencies_json = vim.tbl_extend(
        "error",
        {},
        buffer_json_value["devDependencies"],
        buffer_json_value["dependencies"]
    )

    local installed_dependencies = {}

    for name, version in pairs(all_dependencies_json) do
        installed_dependencies[name] = {
            current = clean_version(version),
        }
    end

    state.buffer.lines = buffer_lines
    state.dependencies.installed = installed_dependencies
end

return M
