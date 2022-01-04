local commands = require("package-info.commands")
local config = require("package-info.config")
local job = require("package-info.utils.job")
local core = require("package-info.core")

local loading = require("package-info.ui.generic.loading-status")

return function(options)
    if not core.__is_valid_package_json() then
        return
    end

    options = options or { force = false }

    if config.state.last_run.should_skip() and options.force == false then
        core.__display_virtual_text()
        core.__reload()

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
            core.__parse_buffer()
            core.__display_virtual_text(outdated_dependencies)
            core.__reload()

            loading.stop(id)

            config.state.last_run.update()
        end,
        on_error = function()
            loading.stop(id)
        end,
    })
end
