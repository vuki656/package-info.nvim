-- FILE DESCRIPTION: Plugin entry point

local config = require("package-info.config")

local core = require("package-info.modules.core")

local M = {}

M.setup = function(options)
    config.setup(options)
end

M.show = function()
    core.show()
end

M.hide = function()
    core.hide()
end

M.delete = function()
    core.delete()
end

M.update = function()
    core.update()
end

M.install = function()
    core.install()
end

return M
