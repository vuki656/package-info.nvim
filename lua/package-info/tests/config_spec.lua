local constants = require("package-info.utils.constants")
local config = require("package-info.config")
local state = require("package-info.state")

local file = require("package-info.tests.utils.file")

describe("Config", function()
    it("should register user options properly", function()
        local new_config = {
            colors = {
                up_to_date = "#ffffff",
                outdated = "#333333",
            },
            icons = {
                enable = false,
                style = {
                    up_to_date = "GG",
                    outdated = "NN",
                },
            },
            autostart = false,
            package_manager = constants.PACKAGE_MANAGERS.yarn,
            hide_up_to_date = true,
            hide_unstable_versions = true,
        }

        config.__register_user_options(new_config)

        assert.are.same(new_config, config.options)
    end)

    it("should keep default options if not changed by the user", function()
        local new_config = {
            colors = {
                up_to_date = "#ffffff",
                outdated = "#333333",
            },
        }

        config.__register_user_options(new_config)

        local merged_config = vim.tbl_deep_extend("keep", config.options, new_config)

        assert.are.equals(vim.inspect(merged_config), vim.inspect(config.options))
    end)

    it("should detect npm package manager", function()
        local file_name = "package-lock.json"

        file.create(file_name)

        config.__register_package_manager()

        file.delete(file_name)

        assert.are.equals(constants.PACKAGE_MANAGERS.npm, config.options.package_manager)
    end)

    it("should detect yarn package manager", function()
        local file_name = "yarn.lock"

        file.create(file_name)

        config.__register_package_manager()

        file.delete(file_name)

        assert.are.equals(constants.PACKAGE_MANAGERS.yarn, config.options.package_manager)
    end)

    it("should detect pnpm package manager", function()
        local file_name = "pnpm-lock.yaml"

        file.create(file_name)

        config.__register_package_manager()

        file.delete(file_name)

        assert.are.equals(constants.PACKAGE_MANAGERS.pnpm, config.options.package_manager)
    end)

    it("should register namespace", function()
        config.__register_namespace()

        assert.are.equals(1, state.namespace.id)
    end)

    it("should register load plugin command", function()
        config.__register_start()

        local autocommands = vim.api.nvim_exec("autocmd BufEnter", true)

        local is_registered = string.find(autocommands, "require('package-info.core').load_plugin()", 0, true)

        assert.is_true(is_registered ~= nil)
    end)

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

        local is_up_to_date_color_registered = string.find(up_to_date_color, config.options.colors.up_to_date, 0, true)
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

    it("should register commands", function()
        config.__register_commands()

        assert.has_no.errors(function()
            for _, command in pairs(constants.COMMANDS) do
                vim.cmd(command)
            end
        end)
    end)
end)
