local constants = require("package-info.utils.constants")
local config = require("package-info.config")
local to_boolean = require("package-info.utils.to-boolean")

local reset = require("package-info.tests.utils.reset")

describe("Config register_colorscheme_initialization", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should register colors", function()
        vim.cmd('let g:colors_name="weird-theme"')

        config.__register_colorscheme_initialization()

        local autocommands = vim.api.nvim_exec("autocmd ColorScheme", true)

        local is_registered = to_boolean(
            string.find(autocommands, "lua require('package-info.config').__register_highlight_groups()", 0, true)
        )

        assert.is_true(is_registered)
    end)

    it("should register colors if default theme is registered", function()
        vim.cmd('let g:colors_name="default"')

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

        assert.is_not_nil(is_outdated_color_registered)
        assert.is_not_nil(is_up_to_date_color_registered)
    end)

    it("should register colors if termguicolors not available", function()
        vim.cmd("set notermguicolors")

        config.__register_colorscheme_initialization()

        local up_to_date_color = vim.api.nvim_exec("highlight " .. constants.HIGHLIGHT_GROUPS.up_to_date, true)
        local outdated_color = vim.api.nvim_exec("highlight " .. constants.HIGHLIGHT_GROUPS.outdated, true)

        local is_up_to_date_color_registered =
            string.find(up_to_date_color, constants.LEGACY_COLORS.up_to_date, 0, true)
        local is_outdated_color_registered = string.find(outdated_color, constants.LEGACY_COLORS.outdated, 0, true)

        assert.is_not_nil(is_outdated_color_registered)
        assert.is_not_nil(is_up_to_date_color_registered)
    end)
end)
