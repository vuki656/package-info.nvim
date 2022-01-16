local state = require("package-info.state")
local logger = require("package-info.utils.logger")

local M = {}

--- Runs the hide virtual text action
-- @return nil
M.run = function()
    if not state.is_loaded then
        logger.warn("Not in valid package.json file")

        return
    end

    state.virtual_text.clear()
end

return M
