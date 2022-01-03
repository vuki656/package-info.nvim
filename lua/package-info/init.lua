-- FILE DESCRIPTION: Plugin entry point
-- TODO: calculate prompt width based on title (package name) length
-- TODO: virtual text background shouldn't be manually set

local config = require("package-info.config")
local utils = require("package-info.utils")

local core = require("package-info.modules.core")

local delete = require("package-info.actions.delete")
local install = require("package-info.actions.install")
local hide = require("package-info.actions.hide")
local change_version = require("package-info.actions.change-version")
local update = require("package-info.actions.update")

local M = {}

M.setup = function(options)
    config.setup(options)
end

M.show = function(options)
    core.show(options)
end

M.hide = function()
    hide()
end

M.delete = function()
    delete()
end

M.update = function()
    update()
end

M.install = function()
    install()
end

M.change_version = function()
    change_version()
end

M.get_status = function()
    return utils.loading.fetch()
end

return M
