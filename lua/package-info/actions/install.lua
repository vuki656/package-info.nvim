local job = require("package-info.utils.job")
local state = require("package-info.state")
local config = require("package-info.config")
local logger = require("package-info.utils.logger")
local refresh = require("package-info.helpers.refresh")
local commands = require("package-info.utils.commands")

local dependency_type_select = require("package-info.ui.dependency-type-select")
local dependency_name_input = require("package-info.ui.dependency-name-input")
local loading = require("package-info.ui.generic.loading-status")

local M = {}

--- Renders the dependency name input
-- @param selected_dependency_type: constants.DEPENDENCY_TYPE - dependency type to determine the install command
-- @return nil
M.__display_dependency_name_input = function(selected_dependency_type)
    dependency_name_input.new({
        on_submit = function(dependency_name)
            local id = loading.new("|  Installing " .. dependency_name .. " dependency")

            job({
                command = commands.install(selected_dependency_type, dependency_name),
                on_start = function()
                    if not config.options.notifications then
                        return
                    end

                    loading.start(id)
                end,
                on_success = function()
                    refresh()

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
