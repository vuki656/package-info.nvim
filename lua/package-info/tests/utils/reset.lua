local core = require("package-info.core")
local state = require("package-info.state")
local constants = require("package-info.utils.constants")
local config = require("package-info.config")

local M = {}

M.core = function()
    core.__dependencies = {}
    core.__outdated_dependencies = {}
    core.__buffer = {}
end

M.config = function()
    config.options = config.__DEFAULT_OPTIONS

    -- Delete all registered autocommands from plugin autogroup
    vim.cmd("autocmd! " .. constants.AUTOGROUP)
end

M.state = function()
    state.buffer.id = nil
    state.last_run.time = nil
    state.namespace.id = nil
end

M.all = function()
    M.core()
    M.config()
    M.state()
end

return M
