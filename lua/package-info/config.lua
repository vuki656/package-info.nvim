local constants = require("package-info.utils.constants")
local highlight_util = require("package-info.utils.register-highlight-group")
local register_autocmd = require("package-info.utils.register-autocmd")
local state = require("package-info.state")
local job = require("package-info.utils.job")
local logger = require("package-info.utils.logger")

local M = {
    __DEFAULT_OPTIONS = {
        highlights = {
            up_to_date = {
                fg = "#3C4048",
                ctermfg = 237,
            },
            outdated = {
                fg = "#d19a66",
                ctermfg = 173,
            },
            invalid = {
                fg = "#ee4b2b",
                ctermfg = 196,
            },
        },
        icons = {
            enable = true,
            style = {
                up_to_date = "|  ",
                outdated = "|  ",
                invalid = "|  ",
            },
        },
        autostart = true,
        notifications = true,
        package_manager = constants.PACKAGE_MANAGERS.npm,
        hide_up_to_date = false,
        hide_unstable_versions = false,
        timeout = 3000,
    },
}

-- Initialize default options
M.options = M.__DEFAULT_OPTIONS

--- Register namespace for usage for virtual text
-- @return nil
M.__register_namespace = function()
    state.namespace.create()
end

-- Check which lock file exists and set package manager accordingly
-- @return nil
M.__register_package_manager = function()
    -- Get the current package.json directory
    local package_json_dir = vim.fn.expand("%:p:h")

    -- If we're not in a package.json file, exit
    if vim.fn.expand("%:t") ~= "package.json" then
        return
    end

    local yarn_lock = io.open(package_json_dir .. "/yarn.lock", "r")

    if yarn_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.yarn

        job({
            command = "yarn -v",
            on_success = function(full_version)
                local major_version = full_version:sub(1, 1)

                if major_version == "1" then
                    state.has_old_yarn = true
                end
            end,
            on_error = function()
                logger.error("Error detecting yarn version. Falling back to yarn <2")
            end,
        })

        io.close(yarn_lock)
        state.is_in_project = true

        return
    end

    local package_lock = io.open(package_json_dir .. "/package-lock.json", "r")

    if package_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.npm

        io.close(package_lock)
        state.is_in_project = true

        return
    end

    local bun_lock = io.open(package_json_dir .. "/bun.lock", "r")

    if bun_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.bun

        io.close(bun_lock)
        state.is_in_project = true

        return
    end

    local pnpm_lock = io.open(package_json_dir .. "/pnpm-lock.yaml", "r")

    if pnpm_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.pnpm

        io.close(pnpm_lock)
        state.is_in_project = true

        return
    end
end

--- Clone options and replace empty ones with default ones
-- @param user_options: M.__DEFAULT_OPTIONS - all the options user can provide in the plugin config
-- @return nil
M.__register_user_options = function(user_options)
    if user_options then
        if user_options.colors and type(user_options.highlights) ~= "table" then
            logger.warn([[
`colors` option is deprecated and will be removed soon.
Please migrate to `highlights` instead.
See README for details.
]])
            user_options.highlights = {
                up_to_date = {
                    fg = type(user_options.colors.up_to_date) == "string" and user_options.colors.up_to_date or nil,
                    ctermfg = type(user_options.colors.up_to_date) == "number" and user_options.colors.up_to_date
                        or nil,
                },
                outdated = {
                    fg = type(user_options.colors.outdated) == "string" and user_options.colors.outdated or nil,
                    ctermfg = type(user_options.colors.outdated) == "number" and user_options.colors.outdated or nil,
                },
                invalid = {
                    fg = type(user_options.colors.invalid) == "string" and user_options.colors.invalid or nil,
                    ctermfg = type(user_options.colors.invalid) == "number" and user_options.colors.invalid or nil,
                },
            }
        end
        user_options.colors = nil
    end

    --- Priority: user highlights options > colorscheme > default
    M.options = vim.tbl_deep_extend("keep", user_options or {}, {
        highlights = highlight_util.get_colorscheme_hl(),
    }, M.__DEFAULT_OPTIONS)
end

--- Prepare a clean augroup for the plugin to use
-- @return nil
M.__prepare_augroup = function()
    vim.cmd("augroup " .. constants.AUTOGROUP)
    vim.cmd("autocmd!")
    vim.cmd("augroup end")
end

--- Register autocommand for loading the plugin
-- @return nil
M.__register_start = function()
    register_autocmd("BufEnter", "lua require('package-info.core').load_plugin()")
end

--- Register autocommand for auto-starting plugin
-- @return nil
M.__register_autostart = function()
    if M.options.autostart then
        register_autocmd("BufEnter", "lua require('package-info').show()")
    end
end

--- Sets the plugin colors after the user colorscheme is loaded
-- @return nil
M.__register_colorscheme_initialization = function()
    M.__register_highlight_groups()
    register_autocmd("ColorScheme", "lua require('package-info.config').__register_highlight_groups()")
end

--- Register all highlight groups
-- @return nil
M.__register_highlight_groups = function()
    for hl_opts_name, hl_group_name in pairs(constants.HIGHLIGHT_GROUPS) do
        highlight_util.set_hl(hl_group_name, M.options.highlights[hl_opts_name])
    end
end

--- Register all plugin commands
-- @return nil
M.__register_commands = function()
    vim.cmd("command! " .. constants.COMMANDS.show .. " lua require('package-info').show()")
    vim.cmd("command! " .. constants.COMMANDS.show_force .. " lua require('package-info').show({ force = true })")
    vim.cmd("command! " .. constants.COMMANDS.hide .. " lua require('package-info').hide()")
    vim.cmd("command! " .. constants.COMMANDS.delete .. " lua require('package-info').delete()")
    vim.cmd("command! " .. constants.COMMANDS.update .. " lua require('package-info').update()")
    vim.cmd("command! " .. constants.COMMANDS.install .. " lua require('package-info').install()")
    vim.cmd("command! " .. constants.COMMANDS.change_version .. " lua require('package-info').change_version()")
end

--- Take all user options and setup the config
-- @param user_options: default M table - all options user can provide in the plugin config
-- @return nil
M.setup = function(user_options)
    M.__register_user_options(user_options)

    M.__register_package_manager()
    M.__register_namespace()
    M.__prepare_augroup()
    M.__register_start()
    M.__register_colorscheme_initialization()
    M.__register_autostart()
    M.__register_commands()
end

return M
