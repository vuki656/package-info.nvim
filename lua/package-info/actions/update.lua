local logger = require("package-info.utils.logger")
local prompt = require("package-info.ui.generic.prompt")
local job = require("package-info.utils.job")
local state = require("package-info.state")
local config = require("package-info.config")
local commands = require("package-info.utils.commands")
local reload = require("package-info.helpers.reload")
local refresh = require("package-info.helpers.refresh")
local get_dependency_name_from_current_line = require("package-info.helpers.get_dependency_name_from_current_line")

local loading = require("package-info.ui.generic.loading-status")

local M = {}

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

    local id = loading.new("| ﯁ Updating " .. dependency_name .. " Dependency")

    prompt.new({
        title = " Update [" .. dependency_name .. "] Dependency ",
        on_submit = function()
            job({
                json = false,
                command = commands.update(dependency_name),
                on_start = function()
                    if not config.options.notifications then
                        return
                    end

                    loading.start(id)
                end,
                on_success = function()
                    refresh()

                    loading.stop(id, "| 󱦟 Updated " .. dependency_name .. " Dependency")
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
