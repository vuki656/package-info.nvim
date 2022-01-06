local commands = require("package-info.commands")
local state = require("package-info.state")
local job = require("package-info.utils.job")
local core = require("package-info.core")

local loading = require("package-info.ui.generic.loading-status")

--- Runs the show outdated dependancies action
-- @return nil
return function(options)
    if not core.is_valid_package_json() then
        return
    end

    options = options or { force = false }

    if state.last_run.should_skip() and options.force == false then
        core.display_virtual_text()
        core.reload()

        return
    end

    local id = loading.new("|  Fetching latest versions")

    job({
        json = true,
        command = commands.get_outdated(),
        ignore_error = true,
        on_start = function()
            loading.start(id)
        end,
        on_success = function(outdated_dependencies)
            core.parse_buffer()
            core.display_virtual_text(outdated_dependencies)
            core.reload()

            loading.stop(id)

            state.last_run.update()
        end,
        on_error = function()
            loading.stop(id)
        end,
    })
end
