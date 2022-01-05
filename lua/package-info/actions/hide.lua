local state = require("package-info.state")

local core = require("package-info.core")

return function()
    core.clear_virtual_text()

    state.displayed = false
end
