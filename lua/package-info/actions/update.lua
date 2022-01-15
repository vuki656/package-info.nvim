local core = require("package-info.core")
local prompt = require("package-info.ui.generic.prompt")
local job = require("package-info.utils.job")
local state = require("package-info.state")
local config = require("package-info.config")
local constants = require("package-info.utils.constants")

local loading = require("package-info.ui.generic.loading-status")

local M = {}

--- Returns the update command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @return string
M.__get_command = function(dependency_name)
    if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
        return "yarn up " .. dependency_name
    end

    if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
        return "npm install " .. dependency_name .. "@latest"
    end

    if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
        return "pnpm update " .. dependency_name
    end
end

--- Runs the update dependency action
-- @return nil
M.run = function()
    if not state.is_loaded() then
        return
    end

    local dependency_name = core.get_dependency_name_from_current_line()

    if dependency_name == nil then
        return
    end

    local id = loading.new("| ﯁ Updating " .. dependency_name .. " package")

    prompt.new({
        title = " Update [" .. dependency_name .. "] Package ",
        on_submit = function()
            job({
                json = false,
                command = M.__get_command(dependency_name),
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
        on_cancel = function()
            loading.stop(id)
        end,
        on_error = function()
            core.reload()

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
