local utils = require("package-info.utils")
local config = require("package-info.config")
local job = require("package-info.utils.job")

local core = require("package-info.core")

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

    utils.loading.start("|  Fetching latest versions")

    job({
        json = true,
        command = utils.get_command.outdated(),
        ignore_error = true,
        on_success = function(outdated_dependencies)
            core.__parse_buffer()
            core.__display_virtual_text(outdated_dependencies)
            core.__reload()

            utils.loading.stop()

            config.state.last_run.update()
        end,
        on_error = function()
            utils.loading.stop()
        end,
    })
end
