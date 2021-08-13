-- FILE DESCRIPTION: Functionality related to buffer parsing

local json_parser = require("package-info.libs.json_parser")

----------------------------------------------------------------------------
---------------------------------- MODULE ----------------------------------
----------------------------------------------------------------------------

local M = {
    json_value = nil,
    raw_value = nil,
}

M.__parse = function()
    local buffer_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local buffer_string_value = table.concat(buffer_content)
    local buffer_json_value = json_parser.decode(buffer_string_value)

    M.json_value = buffer_json_value
    M.raw_value = buffer_content
end

M.validate_package = function(package_name)
    local prod_dependencies, dev_dependencies, peer_dependencies = M.get_dependencies()

    local is_dev_dependency = dev_dependencies[package_name]
    local is_prod_dependency = prod_dependencies[package_name]
    local is_peer_dependency = peer_dependencies[package_name]

    if is_dev_dependency or is_prod_dependency or is_peer_dependency then
        return true
    end

    return false
end

M.get_package_from_line = function(line, should_validate_prop)
    local should_validate_package = should_validate_prop or false

    local package_name = string.match(line, [["(.-)"]])

    if should_validate_package then
        local is_package_valid = M.validate_package(package_name)

        if is_package_valid then
            return package_name
        end

        return nil
    end

    return package_name
end

M.get_package_from_current_line = function()
    local current_line = vim.fn.getline(".")

    return M.get_package_from_line(current_line, true)
end

M.get_dependency_positions = function()
    local buffer_content = M.get_raw()

    local dependency_positions = {}

    for buffer_line_number, buffer_line_content in pairs(buffer_content) do
        local package_name = M.get_package_from_line(buffer_line_content, true)

        if package_name then
            dependency_positions[package_name] = buffer_line_number - 1
        end
    end

    return dependency_positions
end

M.get_dependencies = function()
    local json_value = M.get_json()

    local dev_dependencies = json_value["devDependencies"] or {}
    local prod_dependencies = json_value["dependencies"] or {}
    local peer_dependencies = json_value["peerDependencies"] or {}

    return prod_dependencies, dev_dependencies, peer_dependencies
end

M.get_json = function()
    if M.json_value then
        return M.json_value
    else
        M.__parse()
    end

    return M.json_value
end

M.get_raw = function()
    if M.raw_value then
        return M.raw_value
    else
        M.__parse()
    end

    return M.raw_value
end

return M
