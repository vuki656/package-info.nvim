local state = require("package-info.state")
local config = require("package-info.config")

local M = {}

-- Reset config state and delete all plugin autocommands
-- @return nil
M.config = function()
    config.options = config.__DEFAULT_OPTIONS
    config.__prepare_augroup()
end

-- Reset state state
-- @return nil
M.state = function()
    state.is_loaded = false
    state.is_virtual_text_displayed = false
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
