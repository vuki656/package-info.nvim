-- FILE DESCRIPTION: Plugin entry point
-- TODO: calculate prompt width based on title (package name) length

local config = require("package-info.config")
local utils = require("package-info.utils")

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

M.change_version = function()
    core.change_version()
end

M.get_status = function()
    return utils.loading.fetch()
end

return M
