local config = require("package-info.config")

local core = require("package-info.core")

return function()
    core.__clear_virtual_text()

    config.state.displayed = false
end
