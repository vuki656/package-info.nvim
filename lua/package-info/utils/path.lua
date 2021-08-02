local Module = {}

Module.is_current_file_package_json = function()
    local CURRENT_BUFFER = 0

    local current_file_path = vim.api.nvim_buf_get_name(CURRENT_BUFFER)

    return string.match(current_file_path, "package.json$")
end

return Module
