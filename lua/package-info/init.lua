-- FILE DESCRIPTION: Plugin entry point
-- TODO: calculate prompt width based on title (package name) length
-- TODO: virtual text background shouldn't be manually set

local config = require("package-info.config")
local loading = require("package-info.ui.generic.loading-status")

local delete = require("package-info.actions.delete")
local install = require("package-info.actions.install")
local hide = require("package-info.actions.hide")
local change_version = require("package-info.actions.change-version")
local update = require("package-info.actions.update")
local show = require("package-info.actions.show")

local M = {}

M.setup = function(options)
    config.setup(options)
end

M.show = function(options)
    show(options)
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
    return loading.get()
end

return M
