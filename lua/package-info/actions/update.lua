local logger = require("package-info.utils.logger")
local prompt = require("package-info.ui.generic.prompt")
local job = require("package-info.utils.job")
local state = require("package-info.state")
local config = require("package-info.config")
local constants = require("package-info.utils.constants")
local reload = require("package-info.helpers.reload")
local get_dependency_name_from_current_line = require("package-info.helpers.get_dependency_name_from_current_line")

local loading = require("package-info.ui.generic.loading-status")

local M = {}

--- Returns the update command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @return string
M.__get_command = function(dependency_name)
    if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
        if state.has_old_yarn then
            return "yarn upgrade " .. dependency_name .. " --latest"
        end

        return "yarn up " .. dependency_name
    end

    if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
        return "npm install " .. dependency_name .. "@latest"
    end

    if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
        return "pnpm update --latest " .. dependency_name
    end
end

--- Runs the update dependency action
-- @return nil
M.run = function()
    if not state.is_loaded then
        logger.warn("Not in valid package.json file")

        return
    end

    local dependency_name = get_dependency_name_from_current_line()

    if dependency_name == nil then
        return
    end

    local id = loading.new("| ﯁ Updating " .. dependency_name .. " dependency")

    prompt.new({
        title = " Update [" .. dependency_name .. "] Dependency ",
        on_submit = function()
            job({
                json = false,
                command = M.__get_command(dependency_name),
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
        on_cancel = function()
            loading.stop(id)
        end,
        on_error = function()
            reload()

            loading.stop(id)
        end,
    })

    prompt.open({
        on_error = function()
            loading.stop(id)
        end,
    })
end

return M
