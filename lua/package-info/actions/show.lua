local state = require("package-info.state")
local job = require("package-info.utils.job")
local logger = require("package-info.utils.logger")
local core = require("package-info.core")

local loading = require("package-info.ui.generic.loading-status")

local M = {}

--- Runs the show outdated dependencies action
-- @return nil
M.run = function(options)
    if not state.is_loaded then
        logger.warn("Not in valid package.json file")

        return
    end

    options = options or { force = false }

    if state.last_run.should_skip() and not options.force then
        core.display_virtual_text()
        core.reload()

        return
    end

    local id = loading.new("|  Fetching latest versions")

    job({
        json = true,
        command = "npm outdated --json",
        ignore_error = true,
        on_start = function()
            loading.start(id)
        end,
        on_success = function(outdated_dependencies)
            state.dependencies.outdated = outdated_dependencies

            core.parse_buffer()
            core.display_virtual_text()
            core.reload()

            loading.stop(id)

            state.last_run.update()
        end,
        on_error = function()
            loading.stop(id)
        end,
    })
end

return M
