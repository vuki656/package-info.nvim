local path_utils = require("package-info.utils.path")
local json_utils = require("package-info.utils.json")

local is_file_package_json = path_utils.is_current_file_package_json()

local get_latest_package_version = function(package_name, callback)
    local command = "npm show " .. package_name .. " version"

    vim.fn.jobstart(command, {
        on_stdout = function(_, stdout)
            local latest_package_version = table.concat(stdout)

            callback(latest_package_version)
        end,
    })
end

-- Looks if given string contains package name and package version
local check_line_for_package = function(buffer_line_content, package_name, current_package_version)
    local USE_PLAIN_STRING = true
    local START_INDEX = 0

    local is_name_match = string.find(buffer_line_content, package_name, START_INDEX, USE_PLAIN_STRING)
    local is_version_match = string.find(buffer_line_content, current_package_version, START_INDEX, USE_PLAIN_STRING)

    if is_name_match and is_version_match then
        return true
    end

    return false
end

local set_list_versions = function(buffer_content, dependencies)
    if dependencies == nil then
        return
    end

    for package_name, current_package_version in pairs(dependencies) do
        get_latest_package_version(package_name, function(latest_package_version)
            for buffer_line_number, buffer_line_content in pairs(buffer_content) do
                local is_package_in_line = check_line_for_package(
                    buffer_line_content,
                    package_name,
                    current_package_version
                )

                if is_package_in_line then
                    vim.api.nvim_buf_set_virtual_text(0, 0, buffer_line_number - 1, { { latest_package_version } }, {})
                end
            end
        end)
    end
end

if is_file_package_json then
    local package_json, buffer_content = json_utils.parse_package_json()

    local development_dependencies = package_json["devDependencies"]
    local production_dependencies = package_json["dependencies"]
    local peer_dependencies = package_json["peerDependencies"]

    set_list_versions(buffer_content, development_dependencies)
    set_list_versions(buffer_content, production_dependencies)
    set_list_versions(buffer_content, peer_dependencies)
end
