local state = require("package-info.state")
local constants = require("package-info.utils.constants")
local config = require("package-info.config")

local M = {}

-- Reset config state and delete all plugin autocommands
-- @return nil
M.config = function()
    config.options = config.__DEFAULT_OPTIONS

    -- Delete all registered autocommands from plugin autogroup
    local function reset_autocommands()
        vim.cmd("autocmd! " .. constants.AUTOGROUP)
    end

    if pcall(reset_autocommands) then
        reset_autocommands()
    end
end

-- Reset state state
-- @return nil
M.state = function()
    state.is_loaded = false
    state.virtual_text.is_displayed = false
    state.dependencies.outdated = {}
    state.dependencies.installed = {}
    state.buffer.id = nil
    state.buffer.lines = {}
    state.last_run.time = nil
    state.namespace.id = nil
end

-- Reset everything
-- @return nil
M.all = function()
    M.config()
    M.state()
end

return M
