-- FILE DESCRIPTION: Plugin entry point

local config = require("package-info.config")

local manager_module = require("package-info.modules.manager")
local core_module = require("package-info.modules.core")

local M = {}

M.setup = function(options)
    config.setup(options)
end

M.show = function()
    core_module.show()
end

M.hide = function()
    core_module.hide()
end

M.delete = function()
    manager_module.delete()
end

M.upgrade = function()
    manager_module.upgrade()
end

return M
