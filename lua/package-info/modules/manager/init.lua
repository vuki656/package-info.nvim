local delete = require("package-info.modules.manager.delete")
local upgrade = require("package-info.modules.manager.upgrade")

local M = {}

M.delete = function()
    delete()
end

M.upgrade = function()
    upgrade()
end

return M
