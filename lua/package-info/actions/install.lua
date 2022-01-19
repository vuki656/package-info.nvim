local job = require("package-info.utils.job")
local constants = require("package-info.utils.constants")
local state = require("package-info.state")
local config = require("package-info.config")
local logger = require("package-info.utils.logger")
local reload = require("package-info.helpers.reload")

local dependency_type_select = require("package-info.ui.dependency-type-select")
local dependency_name_input = require("package-info.ui.dependency-name-input")
local loading = require("package-info.ui.generic.loading-status")

local M = {}

--- Returns the install command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @param type: constants.PACKAGE_MANAGERS - package manager for which to get the command
-- @return string
M.__get_command = function(type, dependency_name)
    if type == constants.DEPENDENCY_TYPE.development then
        if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn add -D " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm install --save-dev " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm add -D " .. dependency_name
        end
    end

    if type == constants.DEPENDENCY_TYPE.production then
        if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn add " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm install " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm add " .. dependency_name
        end
    end
end

--- Renders the dependency name input
-- @param selected_dependency_type: constants.DEPENDENCY_TYPE - dependency type to determine the install command
-- @return nil
M.__display_dependency_name_input = function(selected_dependency_type)
    dependency_name_input.new({
        on_submit = function(dependency_name)
            local id = loading.new("|  Installing " .. dependency_name .. " dependency")

            job({
                command = M.__get_command(selected_dependency_type, dependency_name),
                on_start = function()
                    loading.start(id)
                end,
                on_success = function()
                    reload()

                    loading.stop(id)
                end,
                on_error = function()
                    loading.stop(id)
                end,
            })
        end,
    })

    dependency_name_input.open()
end

--- Runs the install new dependency action
-- @return nil
M.run = function()
    if not state.is_in_project then
        logger.info("Not in a JS/TS project")

        return
    end

    dependency_type_select.new({
        on_submit = function(selected_dependency_type)
            M.__display_dependency_name_input(selected_dependency_type)
        end,
    })

    dependency_type_select.open()
end

return M
