local constants = require("package-info.utils.constants")
local register_highlight_group = require("package-info.utils.register-highlight-group")
local register_autocmd = require("package-info.utils.register-autocmd")

-- TODO: Extract state to state.lua
-- FIXME: Config not loaded in correct order

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
}

--- Register namespace for usage for virtual text
M.__register_namespace = function()
    M.namespace = vim.api.nvim_create_namespace("package-info")
end

-- Check which lock file exists and set package manager accordingly
M.__register_package_manager = function()
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
-- @param user_options?: default M table - all the options user can provide in the plugin config
M.__register_user_options = function(user_options)
    M = vim.tbl_deep_extend("force", M, user_options or {})
end

--- Register autocommand for loading the plugin
M.__register_start = function()
    register_autocmd("BufEnter", "lua require('package-info.core').load_plugin()")
end

--- Register autocommand for auto-starting plugin
M.__register_autostart = function()
    if M.autostart then
        register_autocmd("BufEnter", "lua require('package-info').show()")
    end
end

--- Sets the plugin colors after the user colorscheme is loaded
M.__register_colorscheme_initialization = function()
    local colorscheme = vim.api.nvim_exec("colorscheme", true)

    -- If user has no colorscheme(colorscheme is "default"), set the colors manually
    if colorscheme == "default" then
        M.__register_highlight_groups()

        return
    end

    register_autocmd("ColorScheme", "lua require('package-info.config').__register_highlight_groups()")
end

--- Register all highlight groups
M.__register_highlight_groups = function()
    local colors = {
        up_to_date = M.colors.up_to_date,
        outdated = M.colors.outdated,
    }

    -- 256 color support
    if not vim.o.termguicolors then
        colors = {
            up_to_date = "237",
            outdated = "173",
        }
    end

    register_highlight_group(constants.HIGHLIGHT_GROUPS.outdated, colors.outdated)
    register_highlight_group(constants.HIGHLIGHT_GROUPS.up_to_date, colors.up_to_date)
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
-- @param user_options: default M table - all options user can provide in the plugin config
M.setup = function(user_options)
    M.__register_user_options(user_options)

    M.__register_namespace()
    M.__register_package_manager()
    M.__register_start()
    M.__register_colorscheme_initialization()
    M.__register_autostart()
    M.__register_commands()
end

return M
