local state = require("package-info.state")

local core = require("package-info.core")

local M = {}

--- Runs the hide virtual text action
-- @return nil
M.run = function()
    core.clear_virtual_text()

    state.displayed = false
end

return M
