local constants = require("package-info.utils.constants")
local config = require("package-info.config")
local state = require("package-info.state")

describe("Config", function()
    local default_options = config.options

    before_each(function()
        -- Reset options to default ones
        config.options = default_options
    end)

    describe("register_colorscheme_initialization", function()
        it("should register colors", function()
            vim.cmd('let g:colors_name="weird-theme"')
            vim.cmd("colorscheme")

            config.__register_colorscheme_initialization()

            local autocommands = vim.api.nvim_exec("autocmd ColorScheme", true)

            local is_registered = string.find(
                autocommands,
                "lua require('package-info.config').__register_highlight_groups()",
                0,
                true
            )

            assert.is_true(is_registered ~= nil)
        end)

        it("should register colors if default theme is registered", function()
            vim.cmd('let g:colors_name="default"')
            vim.cmd("colorscheme")

            config.__register_colorscheme_initialization()

            assert.has_no.errors(function()
                vim.cmd("highlight " .. constants.HIGHLIGHT_GROUPS.up_to_date)
                vim.cmd("highlight " .. constants.HIGHLIGHT_GROUPS.outdated)
            end)
        end)

        it("should register colors if termguicolors is available", function()
            vim.cmd("set termguicolors")

            config.__register_colorscheme_initialization()

            local up_to_date_color = vim.api.nvim_exec("highlight " .. constants.HIGHLIGHT_GROUPS.up_to_date, true)
            local outdated_color = vim.api.nvim_exec("highlight " .. constants.HIGHLIGHT_GROUPS.outdated, true)

            local is_up_to_date_color_registered = string.find(
                up_to_date_color,
                config.options.colors.up_to_date,
                0,
                true
            )
            local is_outdated_color_registered = string.find(outdated_color, config.options.colors.outdated, 0, true)

            assert.is_true(is_outdated_color_registered ~= nil)
            assert.is_true(is_up_to_date_color_registered ~= nil)
        end)

        it("should register colors if termguicolors not available", function()
            vim.cmd("set notermguicolors")

            config.__register_colorscheme_initialization()

            local up_to_date_color = vim.api.nvim_exec("highlight " .. constants.HIGHLIGHT_GROUPS.up_to_date, true)
            local outdated_color = vim.api.nvim_exec("highlight " .. constants.HIGHLIGHT_GROUPS.outdated, true)

            local is_up_to_date_color_registered = string.find(
                up_to_date_color,
                constants.LEGACY_COLORS.up_to_date,
                0,
                true
            )
            local is_outdated_color_registered = string.find(outdated_color, constants.LEGACY_COLORS.outdated, 0, true)

            assert.is_true(is_outdated_color_registered ~= nil)
            assert.is_true(is_up_to_date_color_registered ~= nil)
        end)
    end)

    describe("register_autostart", function()
        it("should register autostart if autostart option is true", function()
            vim.cmd("autocmd! " .. constants.AUTOGROUP)

            config.__register_autostart()

            local autocommands = vim.api.nvim_exec("autocmd BufEnter", true)

            local is_registered = string.find(autocommands, "lua require('package-info').show()", 0, true)

            assert.is_true(is_registered ~= nil)
        end)

        it("shouldn't register autostart if autostart option is false", function()
            vim.cmd("autocmd! " .. constants.AUTOGROUP)

            config.__register_user_options({ autostart = false })
            config.__register_autostart()

            local autocommands = vim.api.nvim_exec("autocmd BufEnter", true)

            local is_registered = string.find(autocommands, "lua require('package-info').show()", 0, true)

            assert.is_true(is_registered == nil)
        end)
    end)

    describe("register_commands", function()
        it("should register commands", function()
            config.__register_commands()

            assert.has_no.errors(function()
                for _, command in pairs(constants.COMMANDS) do
                    vim.cmd(command)
                end
            end)
        end)
    end)
end)
