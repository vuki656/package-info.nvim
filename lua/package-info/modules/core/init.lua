-- FILE DESCRIPTION: Core module entry point

local hide = require("package-info.modules.core.hide")
local show = require("package-info.modules.core.show")

local M = {}

M.hide = function()
    hide()
end

M.show = function()
    show()
end

return M
