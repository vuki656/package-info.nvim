local constants = require("package-info.utils.constants")
local highlight_util = require("package-info.utils.register-highlight-group")
local register_autocmd = require("package-info.utils.register-autocmd")
local state = require("package-info.state")
local job = require("package-info.utils.job")
local logger = require("package-info.utils.logger")
local is_on_disk = require("package-info.helpers.is_on_disk")
local find_upwards = require("package-info.utils.find-upwards")

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
M.options = vim.deepcopy(M.__DEFAULT_OPTIONS)

--- Register namespace for usage for virtual text
-- @return nil
M.__register_namespace = function()
    state.namespace.create()
end

--- Check which lock file exists and set package manager accordingly
-- @param dir: string
-- @return boolean
local __detect_package_manager = function(dir)
    local yarn_lock = io.open(dir .. "/yarn.lock", "r")

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
        return true
    end

    local package_lock = io.open(dir .. "/package-lock.json", "r")

    if package_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.npm
        io.close(package_lock)
        return true
    end

    local bun_lock = io.open(dir .. "/bun.lock", "r")

    if bun_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.bun
        io.close(bun_lock)
        return true
    end

    local pnpm_lock = io.open(dir .. "/pnpm-lock.yaml", "r")

    if pnpm_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.pnpm
        io.close(pnpm_lock)
        return true
    end

    return false
end

--- Check for a lock file in the package.json directory and every directory
--- above it, so a package in a monorepo picks up the workspace root lock file
-- @return nil
M.__register_package_manager = function()
    -- If we're not in a package.json file, exit
    if vim.fn.expand("%:t") ~= "package.json" then
        return
    end

    if not is_on_disk(vim.fn.expand("%:p")) then
        return
    end

    if find_upwards(vim.fn.expand("%:p:h"), __detect_package_manager) then
        state.is_in_project = true
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
    vim.api.nvim_create_augroup(constants.AUTOGROUP, { clear = true })
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

--- Register autocommand for detecting package manager on package.json entry
-- @return nil
M.__register_package_manager_initialization = function()
    register_autocmd("BufEnter", "lua require('package-info.config').__register_package_manager()")
end

--- Sets the plugin colors after the user colorscheme is loaded
-- @return nil
M.__register_colorscheme_initialization = function()
    M.__register_highlight_groups()
    register_autocmd("ColorScheme", "lua require('package-info.config').__register_highlight_groups()", "*")
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
    local commands = {
        [constants.COMMANDS.show] = {
            desc = "Show the latest version of each dependency",
            callback = function()
                require("package-info").show()
            end,
        },
        [constants.COMMANDS.show_force] = {
            desc = "Show the latest version of each dependency, ignoring the cache",
            callback = function()
                require("package-info").show({ force = true })
            end,
        },
        [constants.COMMANDS.hide] = {
            desc = "Hide the dependency versions",
            callback = function()
                require("package-info").hide()
            end,
        },
        [constants.COMMANDS.toggle] = {
            desc = "Toggle the dependency versions",
            callback = function()
                require("package-info").toggle()
            end,
        },
        [constants.COMMANDS.delete] = {
            desc = "Delete the dependency on the current line",
            callback = function()
                require("package-info").delete()
            end,
        },
        [constants.COMMANDS.update] = {
            desc = "Update the dependency on the current line",
            callback = function()
                require("package-info").update()
            end,
        },
        [constants.COMMANDS.install] = {
            desc = "Install a new dependency",
            callback = function()
                require("package-info").install()
            end,
        },
        [constants.COMMANDS.change_version] = {
            desc = "Change the version of the dependency on the current line",
            callback = function()
                require("package-info").change_version()
            end,
        },
    }

    for name, options in pairs(commands) do
        vim.api.nvim_create_user_command(name, options.callback, { desc = options.desc })
    end
end

--- Take all user options and setup the config
-- @param user_options: default M table - all options user can provide in the plugin config
-- @return nil
M.setup = function(user_options)
    M.__register_user_options(user_options)

    M.__register_namespace()
    M.__prepare_augroup()
    M.__register_package_manager_initialization()
    M.__register_start()
    M.__register_colorscheme_initialization()
    M.__register_autostart()
    M.__register_commands()
end

return M
