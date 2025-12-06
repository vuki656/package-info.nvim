local state = require("package-info.state")
local config = require("package-info.config")
local parser = require("package-info.parser")
local job = require("package-info.utils.job")
local virtual_text = require("package-info.virtual_text")
local reload = require("package-info.helpers.reload")

local loading = require("package-info.ui.generic.loading-status")

local pnpm_workspace_path = vim.fn.getcwd() .. "/pnpm-workspace.yaml"

local function has_workspace()
    return vim.fn.filereadable(pnpm_workspace_path) == 1
end

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
        command = has_workspace() and "pnpm outdated --json" or "npm outdated --json",
        ignore_error = true,
        on_start = function()
            if not config.options.notifications then
                return
            end

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

    if has_workspace() then
        local workspace_message = "| 󰇚 Fetching pnpm workspace"
        local workspace_id = loading.new(workspace_message)
        job({
            json = true,
            command = "cat " .. pnpm_workspace_path .. " | yq -o json",
            ignore_error = true,
            on_start = function()
                if not config.options.notifications then
                    return
                end

                loading.start(workspace_id)
            end,
            on_success = function(workspace)
                state.dependencies.pnpm_workspace = workspace

                loading.stop(workspace_id, workspace_message)

                state.last_run.update()
            end,
            on_error = function()
                loading.stop(workspace_id, workspace_message, vim.log.levels.ERROR)
            end,
        })
    end
end

return M
