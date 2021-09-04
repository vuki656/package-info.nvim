-- FILE DESCRIPTION: Plugin entry point

local config = require("package-info.config")

local core_module = require("package-info._modules.core")

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

-- M.delete = function()
--     manager_module.delete()
-- end

return M
