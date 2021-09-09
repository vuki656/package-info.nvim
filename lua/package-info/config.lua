-- DESCRIPTION: sets up the user given config, and plugin config

local constants = require("package-info.constants")

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
    package_manager = constants.PACKAGE_MANAGERS.yarn,
    hide_up_to_date = false,
    hide_unstable_versions = false,

    __highlight_params = {
        fg = "guifg",
    },
}

M.namespace = {
    id = "",
    register = function()
        M.namespace.id = vim.api.nvim_create_namespace("package-ui")
    end,
}

M.state = {
    buffer_id = nil,
    displayed = false,
    last_run = nil,
    should_skip = function()
        local hour_in_seconds = 3600

        if M.state.last_run == nil then
            return false
        end

        return os.time() < M.state.last_run + hour_in_seconds
    end,
    update_last_run = function()
        M.state.last_run = os.time()
    end,
    store_buffer_id = function()
        M.state.buffer_id = vim.fn.bufnr()
    end,
}

-- Check if yarn.lock or package-lock.json exist and set package manager accordingly
M.__detect_package_manager = function()
    local package_lock = io.open("package-lock.json", "r")
    local yarn_lock = io.open("yarn.lock", "r")

    if package_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.npm
        io.close(package_lock)
    end

    if yarn_lock ~= nil then
        M.options.package_manager = constants.PACKAGE_MANAGERS.yarn
        io.close(yarn_lock)
    end
end

--- Clone options and replace empty ones with default ones
-- @param user_options - all the options user can provide in the plugin config // See M.options for defaults
M.__register_user_options = function(user_options)
    M.__detect_package_manager()
    M.options = vim.tbl_deep_extend("force", {}, M.options, user_options or {})
end

--- Register autocommand for auto-starting plugin
M.__register_autostart = function()
    vim.api.nvim_exec(
        [[augroup PackageUI
             autocmd!
             autocmd BufEnter * lua require("package-info.modules.core3").load_plugin()
         augroup end]],
        false
    )

    -- TODO: implement
    if M.options.autostart then
        -- vim.api.nvim_exec(
        --     [[augroup PackageUI
        --         autocmd!
        --         autocmd BufEnter * lua require("package-info").show()
        --     augroup end]],
        --     false
        -- )
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
