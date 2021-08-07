local json_parser = require("package-info.libs.json_parser")

local M = {}

-- For each JSON line check if its content can be found in the dependency list,
-- if yes, get its position
M.get_dependency_positions = function(json_value)
    local buffer_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    local dev_dependencies = json_value["devDependencies"] or {}
    local prod_dependencies = json_value["dependencies"] or {}
    local peer_dependencies = json_value["peerDependencies"] or {}

    local dependency_positions = {}

    for buffer_line_number, buffer_line_content in pairs(buffer_content) do
        for match in string.gmatch(buffer_line_content, [["(.-)"]]) do
            local is_dev_dependency = dev_dependencies[match]
            local is_prod_dependency = prod_dependencies[match]
            local is_peer_dependency = peer_dependencies[match]

            if is_dev_dependency or is_prod_dependency or is_peer_dependency then
                dependency_positions[match] = buffer_line_number - 1
            end
        end
    end

    return dependency_positions
end

-- Takes current buffer content and converts it to a JSON table
M.parse_buffer = function()
    local buffer_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local buffer_string_value = table.concat(buffer_content)
    local buffer_json_value = json_parser.decode(buffer_string_value)

    return buffer_json_value
end

return M
