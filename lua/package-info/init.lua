-- TODO: check if there is a text changes event, if so, redraw the dependencies in the buffer, TextChanged autocmd

local M = {}

M.setup = function(options)
    local config = require("package-info.config")

    config.setup(options)
end

M.show = function(options)
    local show_action = require("package-info.actions.show")

    show_action.run(options)
end

M.hide = function()
    local hide_action = require("package-info.actions.hide")

    hide_action.run()
end

M.toggle = function(options)
    local state = require("package-info.state")

    if state.is_virtual_text_displayed then
        M.hide()
    else
        M.show(options)
    end
end

M.delete = function()
    local delete_action = require("package-info.actions.delete")

    delete_action.run()
end

M.update = function()
    local update_action = require("package-info.actions.update")

    update_action.run()
end

M.install = function()
    local install_action = require("package-info.actions.install")

    install_action.run()
end

M.change_version = function()
    local change_version_action = require("package-info.actions.change-version")

    change_version_action.run()
end

M.get_status = function()
    local loading = require("package-info.ui.generic.loading-status")

    return loading.get()
end

return M
