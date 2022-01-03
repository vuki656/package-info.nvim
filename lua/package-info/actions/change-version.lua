local Menu = require("nui.menu")

local config = require("package-info.config")
local utils = require("package-info.utils")
local job = require("package-info.utils.job")

local dependency_version_select = require("package-info.ui.dependency-version-select")

local core = require("package-info.core")

return function()
    local dependency_name = core.__get_dependency_name_from_current_line()

    utils.loading.start("|  Fetching " .. dependency_name .. " versions")

    job({
        json = true,
        command = utils.get_command.version_list(dependency_name),
        on_success = function(versions)
            utils.loading.stop()

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

            dependency_version_select.new({
                version_list = version_list,
                on_submit = function(selected_version)
                    local command = utils.get_command.change_version(dependency_name, selected_version)

                    utils.loading.start("|  Installing " .. dependency_name .. "@" .. selected_version)

                    utils.job({
                        command = command,
                        on_success = function()
                            core.__reload()

                            utils.loading.stop()
                        end,
                        on_error = function()
                            utils.loading.stop()
                        end,
                    })
                end,
            })

            dependency_version_select.open()
        end,
        on_error = function()
            utils.loading.stop()
        end,
    })
end
