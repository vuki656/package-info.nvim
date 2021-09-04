-- FILE DESCRIPTION: Plugin entry point

local config = require("package-info.config")

local core = require("package-info.modules.core")

local M = {}

M.setup = function(options)
    config.setup(options)
end

M.show = function(options)
    core.show(options)
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

M.reinstall = function()
    core.reinstall()
end

M.get_status = function()
    return config.loading.fetch()
end

return M
