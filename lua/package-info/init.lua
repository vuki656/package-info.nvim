-- TODO: tests
-- TODO: yarn 1 support

local M = {}

M.setup = function(options)
    local config = require("package-info.config")

    config.setup(options)
end

M.show = function(options)
    local show = require("package-info.actions.show")

    show(options)
end

M.hide = function()
    local hide = require("package-info.actions.hide")

    hide()
end

M.delete = function()
    local delete = require("package-info.actions.delete")

    delete()
end

M.update = function()
    local update = require("package-info.actions.update")

    update()
end

M.install = function()
    local install = require("package-info.actions.install")

    install()
end

M.change_version = function()
    local change_version = require("package-info.actions.change-version")

    change_version()
end

M.get_status = function()
    local loading = require("package-info.ui.generic.loading-status")

    return loading.get()
end

return M
