local constants = require("package-info.utils.constants")
local state = require("package-info.state")
local config = require("package-info.config")

local spy = require("package-info.tests.utils.spy")

local M = {}

-- Reset config state and delete all plugin autocommands
-- @return nil
M.config = function()
    config.options = vim.deepcopy(config.__DEFAULT_OPTIONS)
    config.__prepare_augroup()
end

-- Reset state state
-- @return nil
M.state = function()
    state.is_in_project = false
    state.is_loaded = false
    state.is_virtual_text_displayed = false
    state.has_old_yarn = false
    state.dependencies.outdated = {}
    state.dependencies.installed = {}
    state.dependencies.invalid = {}
    state.dependencies.pnpm_workspace = {}
    state.buffer.id = nil
    state.buffer.path = nil
    state.buffer.lines = {}
    state.buffer.package_name = nil
    state.last_run.time = nil
    state.namespace.id = nil
end

-- Clear the plugin highlight groups so they cannot leak between test cases
-- @return nil
M.highlights = function()
    for _, hl_group_name in pairs(constants.HIGHLIGHT_GROUPS) do
        pcall(vim.api.nvim_set_hl, 0, hl_group_name, {})
    end
end

-- Reset everything
-- @return nil
M.all = function()
    spy.revert_all()
    M.config()
    M.state()
    M.highlights()
end

return M
