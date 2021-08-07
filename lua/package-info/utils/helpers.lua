local M = {}

M.register_highlight_group = function(group, color)
    vim.cmd("highlight " .. group .. " guifg=" .. color)
end

M.is_file_package_json = function()
    local current_buffer_name = vim.api.nvim_buf_get_name(0)
    local result = string.match(current_buffer_name, "package.json$")

    if result then
        return true
    end

    return false
end

return M
