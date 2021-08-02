function check_if_file_package_json(path)
    return string.match(path, "package.json$")
end

local CURRENT_BUFFER = 0

local current_file_path = vim.api.nvim_buf_get_name(CURRENT_BUFFER)

local is_file_package_json = check_if_file_package_json(current_file_path)

if is_file_package_json then
    print("Im a package.json")
end
