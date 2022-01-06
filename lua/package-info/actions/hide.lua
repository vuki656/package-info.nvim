local state = require("package-info.state")

local core = require("package-info.core")

--- Runs the hide virtual text action
-- @return nil
return function()
    core.clear_virtual_text()

    state.displayed = false
end
