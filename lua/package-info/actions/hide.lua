local state = require("package-info.state")
local logger = require("package-info.utils.logger")
local core = require("package-info.core")

local M = {}

--- Runs the hide virtual text action
-- @return nil
M.run = function()
    if not state.is_loaded then
        logger.warn("Not in valid package.json file")

        return
    end

    core.clear_virtual_text()

    state.virtual_text.is_displayed = false
end

return M
