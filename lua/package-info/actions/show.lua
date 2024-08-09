local state = require("package-info.state")
local parser = require("package-info.parser")
local job = require("package-info.utils.job")
local virtual_text = require("package-info.virtual_text")
local reload = require("package-info.helpers.reload")

local loading = require("package-info.ui.generic.loading-status")

local M = {}

--- Runs the show outdated dependencies action
-- @return nil
M.run = function(options)
    if not state.is_loaded then
        return
    end

    reload()

    options = options or { force = false }

    if state.last_run.should_skip() and not options.force then
        virtual_text.display()
        reload()

        return
    end

    local loading_message = "| 󰇚 Fetching latest versions"
    local id = loading.new(loading_message)

    job({
        json = true,
        command = "npm outdated --json",
        ignore_error = true,
        on_start = function()
            loading.start(id)
        end,
        on_success = function(outdated_dependencies)
            state.dependencies.outdated = outdated_dependencies

            if vim.api.nvim_buf_is_valid(state.buffer.id) and vim.api.nvim_buf_is_loaded(state.buffer.id) then
                parser.parse_buffer()
                virtual_text.display()
                reload()
            end

            loading.stop(id, loading_message)

            state.last_run.update()
        end,
        on_error = function()
            loading.stop(id, loading_message, vim.log.levels.ERROR)
        end,
    })
end

return M
