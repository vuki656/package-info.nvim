-- DESCRIPTION: sets up the user given config, and plugin config

local constants = require("package-info.constants")
local register_highlight_group = require("package-info.utils.register-highlight-group")
local register_autocmd = require("package-info.utils.register-autocmd")

----------------------------------------------------------------------------
---------------------------------- MODULE ----------------------------------
----------------------------------------------------------------------------

--- Default options
local M = {
    colors = {
        up_to_date = "#3C4048",
        outdated = "#d19a66",
    },
    icons = {
        enable = true,
        style = {
            up_to_date = "|  ",
            outdated = "|  ",
        },
    },
    autostart = true,
    namespace = "",
    package_manager = constants.PACKAGE_MANAGERS.yarn,
    hide_up_to_date = false,
    hide_unstable_versions = false,

    __highlight_params = {
        fg = "guifg",
    },
}

--- Register namespace for usage for virtual text
M.__register_namespace = function()
    M.namespace = vim.api.nvim_create_namespace("package-info")
end

-- Check if yarn.lock or package-lock.json exist and set package manager accordingly
M.__register_package_manager = function()
    -- TODO: do we need to detect yarn if its the default
    local yarn_lock = io.open("yarn.lock", "r")

    if yarn_lock ~= nil then
        M.package_manager = constants.PACKAGE_MANAGERS.yarn

        io.close(yarn_lock)

        return
    end

    local package_lock = io.open("package-lock.json", "r")

    if package_lock ~= nil then
        M.package_manager = constants.PACKAGE_MANAGERS.npm

        io.close(package_lock)

        return
    end

    local pnpm_lock = io.open("pnpm-lock.yaml", "r")

    if pnpm_lock ~= nil then
        M.package_manager = constants.PACKAGE_MANAGERS.pnpm

        io.close(pnpm_lock)

        return
    end
end

--- Clone options and replace empty ones with default ones
-- @param user_options - all the options user can provide in the plugin config
M.__register_user_options = function(user_options)
    M = vim.tbl_deep_extend("force", {}, M, user_options or {})
end

--- Register autocommand for loading plugin
M.__register_plugin_loading = function()
    register_autocmd("BufEnter", "lua require('package-info.core').load_plugin()")
end

--- Register autocommand for auto-starting plugin
M.__register_autostart = function()
    if M.autostart then
        register_autocmd("BufEnter", "lua require('package-info').show()")
    end
end

--- If terminal doesn't support true color, fallback to 256 config
M.__register_256color_support = function()
    -- Skip if terminal supports gui colors
    if vim.o.termguicolors then
        return
    end

    register_autocmd("ColorScheme", "lua require('package-info.config').__register_highlight_groups()")

    M.colors = {
        up_to_date = "237",
        outdated = "173",
    }

    M.__highlight_params.fg = "ctermfg"
end

--- Register all highlight groups
M.__register_highlight_groups = function()
    register_highlight_group(constants.HIGHLIGHT_GROUPS.outdated, M.colors.outdated, M.__highlight_params.fg)
    register_highlight_group(constants.HIGHLIGHT_GROUPS.up_to_date, M.colors.up_to_date, M.__highlight_params.fg)
end

--- Register all plugin commands
M.__register_commands = function()
    vim.cmd([[ 
        command! PackageInfoShow lua require('package-info').show()
        command! PackageInfoShowForce lua require('package-info').show({ force = true })
        command! PackageInfoHide lua require('package-info').hide()
        command! PackageInfoDelete lua require('package-info').delete()
        command! PackageInfoUpdate lua require('package-info').update()
        command! PackageInfoInstall lua require('package-info').install()
        command! PackageInfoChangeVersion lua require('package-info').change_version()
    ]])
end

--- Take all user options and setup the config
-- @param user_options - all the options user can provide in the plugin config // See M for defaults
M.setup = function(user_options)
    M.__register_namespace()
    M.__register_package_manager()
    M.__register_user_options(user_options)
    M.__register_plugin_loading()
    M.__register_autostart()
    M.__register_256color_support()
    M.__register_highlight_groups()
    M.__register_commands()
end

return M
