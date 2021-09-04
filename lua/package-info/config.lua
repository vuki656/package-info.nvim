-- DESCRIPTION: sets up the user given config, and plugin config

local constants = require("package-info.constants")
local logger = require("package-info.logger")

----------------------------------------------------------------------------
---------------------------------- MODULE ----------------------------------
----------------------------------------------------------------------------

local M = {}

--- Default options
M.options = {
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
    package_manager = "yarn",
    hide_up_to_date = false,

    __highlight_params = {
        fg = "guifg",
    },
}

M.get_command = {
    --- Returns the delete command based on package manager
    -- @param package-name - string
    delete = function(package_name)
        if M.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn remove " .. package_name
        end

        if M.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm uninstall " .. package_name
        end
    end,

    --- Returns the update command based on package manager
    -- @param package-name - string
    update = function(package_name)
        if M.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn upgrade --latest " .. package_name
        end

        if M.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm install " .. package_name .. "@latest"
        end
    end,

    install = function(type, package_name)
        if type == constants.DEPENDENCY_TYPE.dev then
            if M.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
                return "yarn add -D " .. package_name
            end

            if M.options.package_manager == constants.PACKAGE_MANAGERS.npm then
                return "npm install --save-dev " .. package_name
            end
        end

        if type == constants.DEPENDENCY_TYPE.prod then
            if M.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
                return "yarn add " .. package_name
            end

            if M.options.package_manager == constants.PACKAGE_MANAGERS.npm then
                return "npm install " .. package_name
            end
        end
    end,
}

M.namespace = {
    id = "",
    --- Registers the namespace for the plugin
    register = function()
        M.namespace.id = vim.api.nvim_create_namespace("package-ui")
    end,
}

M.state = {
    displayed = M.options.autostart or false,
    last_run = nil,
    should_skip = function()
        local hour_in_seconds = 3600

        if M.state.last_run == nil then
            return false
        end

        return os.time() < M.state.last_run + hour_in_seconds
    end,
}

M.loading = {
    animation = {
        "⠋",
        "⠙",
        "⠹",
        "⠸",
        "⠼",
        "⠴",
        "⠦",
        "⠧",
        "⠇",
        "⠏",
    },
    index = 1,
    log = "",
    spinner = "",
    is_running = false,
    fetch = function()
        return M.loading.spinner .. " " .. M.loading.log
    end,
    start = function(message)
        M.loading.log = message
        M.loading.is_running = true
        M.loading.update()
    end,
    stop = function()
        M.loading.is_running = false
        M.loading.log = ""
        M.loading.spinner = ""
    end,
    update = function()
        if M.loading.is_running then
            M.loading.spinner = M.loading.animation[M.loading.index]

            M.loading.index = M.loading.index + 1

            if M.loading.index == 10 then
                M.loading.index = 1
            end

            vim.fn.timer_start(80, function()
                M.loading.update()
            end)
        end
    end,
}

--- Clone options and replace empty ones with default ones
-- @param user_options - all the options user can provide in the plugin config // See M.options for defaults
M.__register_user_options = function(user_options)
    if
        user_options.package_manager ~= constants.PACKAGE_MANAGERS.yarn
        and user_options.package_manager ~= constants.PACKAGE_MANAGERS.npm
    then
        logger.error("Invalid package manager. Can be `npm` or `yarn`. Using default `yarn`.")

        M.package_manager = constants.PACKAGE_MANAGERS.yarn
    end

    M.options = vim.tbl_deep_extend("force", {}, M.options, user_options or {})
end

--- Register autocommand for auto-starting plugin
M.__register_autostart = function()
    if M.options.autostart then
        vim.api.nvim_exec(
            [[augroup PackageUI
                autocmd!
                autocmd BufWinEnter * lua require("package-info").show()
            augroup end]],
            false
        )
    end
end

--- If terminal doesn't support true color, fallback to 256 config
M.__register_256color_support = function()
    if not vim.o.termguicolors then
        vim.cmd([[
          augroup PackageUIHighlight
            autocmd!
            autocmd ColorScheme * lua require('package-info.config').__register_highlight_groups()
          augroup END
        ]])

        M.options.colors = {
            up_to_date = "237",
            outdated = "173",
        }

        M.options.__highlight_params.fg = "ctermfg"
    end
end

--- Register given highlight group
-- @param group - highlight group
-- @param color - color to use with the highlight group
M.__register_highlight_group = function(group, color)
    vim.cmd("highlight " .. group .. " " .. M.options.__highlight_params.fg .. "=" .. color)
end

--- Register all highlight groups
M.__register_highlight_groups = function()
    M.__register_highlight_group(constants.HIGHLIGHT_GROUPS.outdated, M.options.colors.outdated)
    M.__register_highlight_group(constants.HIGHLIGHT_GROUPS.up_to_date, M.options.colors.up_to_date)
end

--- Take all user options and setup the config
-- @param user_options - all the options user can provide in the plugin config // See M.options for defaults
M.setup = function(user_options)
    M.__register_user_options(user_options)
    M.__register_autostart()
    M.__register_256color_support()
    M.__register_highlight_groups()
    M.namespace.register()
end

return M
