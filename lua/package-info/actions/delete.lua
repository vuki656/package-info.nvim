local prompt = require("package-info.ui.generic.prompt")
local job = require("package-info.utils.job")
local config = require("package-info.config")
local logger = require("package-info.utils.logger")
local state = require("package-info.state")
local get_dependency_name_from_current_line = require("package-info.helpers.get_dependency_name_from_current_line")
local refresh = require("package-info.helpers.refresh")
local commands = require("package-info.utils.commands")

local loading = require("package-info.ui.generic.loading-status")

local M = {}

--- Runs the delete action
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

    local id = loading.new("|  Deleting " .. dependency_name .. " dependency")

    prompt.new({
        title = " Delete [" .. dependency_name .. "] Dependency ",
        on_submit = function()
            job({
                json = false,
                command = commands.delete(dependency_name),
                on_start = function()
                    if not config.options.notifications then
                        return
                    end

                    loading.start(id)
                end,
                on_success = function()
                    refresh()

                    loading.stop(id, "|  Deleted " .. dependency_name .. " dependency", vim.log.levels.INFO)
                end,
                on_error = function()
                    loading.stop(
                        id,
                        "|  Failed to delete " .. dependency_name .. " dependency",
                        vim.log.levels.ERROR
                    )
                end,
            })
        end,
        on_cancel = function()
            loading.stop(id, "|  Canceled deleting " .. dependency_name .. " dependency", vim.log.levels.WARN)
        end,
    })

    prompt.open({
        on_error = function()
            loading.stop(id, "|  Failed to delete " .. dependency_name .. " dependency", vim.log.levels.ERROR)
        end,
    })
end

return M
