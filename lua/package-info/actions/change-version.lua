local Menu = require("nui.menu")

local config = require("package-info.config")
local loading = require("package-info.ui.generic.loading-status")
local commands = require("package-info.commands")
local job = require("package-info.utils.job")
local core = require("package-info.core")

local dependency_version_select = require("package-info.ui.dependency-version-select")

-- TODO: doc
function display_dependency_version_select(version_list, dependency_name)
    dependency_version_select.new({
        version_list = version_list,
        on_submit = function(selected_version)
            local id = loading.new("|  Installing " .. dependency_name .. "@" .. selected_version)

            job({
                command = commands.get_change_version(dependency_name, selected_version),
                on_start = function()
                    loading.start(id)
                end,
                on_success = function()
                    core.reload()

                    loading.stop(id)
                end,
                on_error = function()
                    loading.stop(id)
                end,
            })
        end,
    })

    dependency_version_select.open()
end

-- TODO: doc
function create_select_items(versions)
    local version_list = {}

    -- Iterate versions from the end to show the latest versions first
    for index = #versions, 1, -1 do
        local version = versions[index]

        -- TODO: cleanup stupid if else logic
        --  Skip unstable version e.g next@11.1.0-canary
        if config.options.hide_unstable_versions and string.match(version, "-") then
        else
            table.insert(version_list, Menu.item(version))
        end
    end

    return version_list
end

return function()
    local dependency_name = core.get_dependency_name_from_current_line()

    local id = loading.new("|  Fetching " .. dependency_name .. " versions")

    job({
        json = true,
        command = commands.get_version_list(dependency_name),
        on_start = function()
            loading.start(id)
        end,
        on_success = function(versions)
            loading.stop(id)

            local version_list = create_select_items(versions)

            display_dependency_version_select(version_list, dependency_name)
        end,
        on_error = function()
            loading.stop(id)
        end,
    })
end
