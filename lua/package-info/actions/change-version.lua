local Menu = require("nui.menu")

local config = require("package-info.config")
local loading = require("package-info.ui.generic.loading-status")
local job = require("package-info.utils.job")
local logger = require("package-info.utils.logger")
local state = require("package-info.state")
local get_dependency_name_from_current_line = require("package-info.helpers.get_dependency_name_from_current_line")
local refresh = require("package-info.helpers.refresh")
local commands = require("package-info.utils.commands")

local dependency_version_select = require("package-info.ui.dependency-version-select")

local M = {}

--- Display dependency version select UI
-- @param version_list: Menu.item[] - items to be rendered in the menu
-- @param dependency_name: string - dependency for which to run change version command
-- @return nil
M.__display_dependency_version_select = function(version_list, dependency_name)
    dependency_version_select.new({
        version_list = version_list,
        on_submit = function(selected_version)
            local loading_name = dependency_name .. "@" .. selected_version
            local id = loading.new("| 󰆓 Installing " .. loading_name)

            job({
                command = commands.change_version(dependency_name, selected_version),
                on_start = function()
                    if not config.options.notifications then
                        return
                    end

                    loading.start(id)
                end,
                on_success = function()
                    refresh()

                    loading.stop(id, "| 󱣪 Installed " .. loading_name .. " successfully", vim.log.levels.INFO)
                end,
                on_error = function()
                    loading.stop(id, "| 󱙃 Failed to install " .. loading_name, vim.log.levels.ERROR)
                end,
            })
        end,
    })

    dependency_version_select.open()
end

--- Maps output from command to menu items
-- @param versions: string[] - versions to map to menu items
-- @return Menu.item[] - versions mapped to menu items
M.__create_select_items = function(versions)
    local version_list = {}

    -- Iterate versions from the end to show the latest versions first
    for index = #versions, 1, -1 do
        local version = versions[index]
        local is_unstable = string.match(version, "-")

        --  Skip unstable version e.g next@11.1.0-canary
        if is_unstable then
            if not config.options.hide_unstable_versions then
                table.insert(version_list, Menu.item(version))
            end
        else
            table.insert(version_list, Menu.item(version))
        end
    end

    return version_list
end

--- Runs the change version action
-- @return nil
M.run = function()
    if not state.is_loaded then
        logger.warn("Not in valid package.json file")

        return
    end

    local dependency_name = get_dependency_name_from_current_line()

    if not dependency_name then
        return
    end

    local loading_message = "| 󰇚 Fetching latest versions"
    local id = loading.new(loading_message)

    job({
        json = true,
        command = commands.version_list(dependency_name),
        on_start = function()
            if not config.options.notifications then
                return
            end

            loading.start(id)
        end,
        on_success = function(versions)
            loading.stop(id, loading_message)

            local version_list = M.__create_select_items(versions)

            M.__display_dependency_version_select(version_list, dependency_name)
        end,
        on_error = function()
            loading.stop(id, loading_message, vim.log.levels.ERROR)
        end,
    })
end

return M
