local state = require("package-info.state")

local core = require("package-info.core")

return function()
    core.__clear_virtual_text()

    state.state.displayed = false
end
