local json_parser = require("package-info.libs.json_parser")

local HIGHLIGHT_GROUPS = {
    outdated = "PackageInfoOutdatedVersion",
    up_to_date = "PackageInfoUpToDateVersion",
}

local HIGHLIGHT_ICONS = {
    outdated = "|  ",
    up_to_date = "|  ",
}

-- Get latest version for a given package
local get_latest_package_version = function(package_name, callback)
    local command = "npm show " .. package_name .. " version"

    vim.fn.jobstart(command, {
        on_stdout = function(_, stdout)
            local latest_package_version = table.concat(stdout)

            callback(latest_package_version)
        end,
    })
end

-- Set latest version as virtual text for each dependency
local set_virtual_text = function(dependencies, dependency_positions)
    for package_name, current_package_version in pairs(dependencies) do
        get_latest_package_version(package_name, function(latest_package_version)
            local highlight = {
                group = HIGHLIGHT_GROUPS.up_to_date,
                icon = HIGHLIGHT_ICONS.up_to_date,
            }

            if latest_package_version ~= current_package_version then
                highlight.group = HIGHLIGHT_GROUPS.outdated
                highlight.icon = HIGHLIGHT_ICONS.outdated
            end

            vim.api.nvim_buf_set_virtual_text(
                0,
                0,
                dependency_positions[package_name],
                { { highlight.icon .. latest_package_version, highlight.group } },
                {}
            )
        end)
    end
end

-- For each JSON line check if its content can be found in the dependency list,
-- if yes, get its position
local get_dependency_positions = function(json_value)
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
local parse_buffer = function()
    local buffer_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local buffer_string_value = table.concat(buffer_content)
    local buffer_json_value = json_parser.decode(buffer_string_value)

    return buffer_json_value
end

local M = {}

M.setup = function()
    -- Register autocommand for auto-starting plugin
    vim.api.nvim_exec(
        [[augroup PackageUI
            autocmd!
            autocmd BufWinEnter,WinNew * lua require("package-info").setup()
        augroup end]],
        false
    )

    vim.cmd("highlight PackageInfoOutdatedVersion guifg=#ef596f gui=italic")
    vim.cmd("highlight PackageInfoUpToDateVersion guifg=#89ca78 gui=italic")

    local current_file_path = vim.api.nvim_buf_get_name(0)
    local is_file_package_json = string.match(current_file_path, "package.json$")

    if is_file_package_json then
        local json_value = parse_buffer()

        local dependency_positions = get_dependency_positions(json_value)

        local dev_dependencies = json_value["devDependencies"] or {}
        local prod_dependencies = json_value["dependencies"] or {}
        local peer_dependencies = json_value["peerDependencies"] or {}

        set_virtual_text(dev_dependencies, dependency_positions)
        set_virtual_text(prod_dependencies, dependency_positions)
        set_virtual_text(peer_dependencies, dependency_positions)
    end
end

return M
