local buffer_parser = require("package-info.buffer_parser")
local ui = require("package-info.ui")
local config = require("package-info.config")

local M = {}

M.display = function()
    local is_file_package_json = string.match(vim.api.nvim_buf_get_name(0), "package.json$")

    if is_file_package_json then
        local json_value = buffer_parser.parse_buffer()
        local dependency_positions = buffer_parser.get_dependency_positions(json_value)

        local dev_dependencies = json_value["devDependencies"] or {}
        local prod_dependencies = json_value["dependencies"] or {}
        local peer_dependencies = json_value["peerDependencies"] or {}

        ui.set_virtual_text(dev_dependencies, dependency_positions)
        ui.set_virtual_text(prod_dependencies, dependency_positions)
        ui.set_virtual_text(peer_dependencies, dependency_positions)
    end
end

M.clear = function()
    vim.api.nvim_buf_clear_namespace(0, config.namespace_id, 0, -1)
end

M.setup = function(options)
    config.setup_options(options)
    config.register_auto_start()
    config.register_highlights()
end

return M
