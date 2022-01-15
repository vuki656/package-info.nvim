local state = require("package-info.state")

local core = require("package-info.core")

local M = {}

--- Runs the hide virtual text action
-- @return nil
M.run = function()
    if not state.is_loaded() then
        return
    end

    core.clear_virtual_text()

    state.displayed = false
end

return M
