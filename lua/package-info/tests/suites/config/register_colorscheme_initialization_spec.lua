local expect = MiniTest.expect

local constants = require("package-info.utils.constants")
local config = require("package-info.config")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should register colors"] = function()
    vim.g.colors_name = "weird-theme"

    config.__register_colorscheme_initialization()

    local autocommands = vim.api.nvim_get_autocmds({ event = "ColorScheme" })

    local is_registered = false

    for _, autocommand in ipairs(autocommands) do
        if autocommand.command == "lua require('package-info.config').__register_highlight_groups()" then
            is_registered = true
        end
    end

    expect.equality(is_registered, true)
end

T["should register the colorscheme autocommand against every colorscheme"] = function()
    config.__register_colorscheme_initialization()

    local autocommands = vim.api.nvim_get_autocmds({
        group = constants.AUTOGROUP,
        event = "ColorScheme",
    })

    expect.equality(#autocommands, 1)
    expect.equality(autocommands[1].pattern, "*")
end

T["should register colors if default theme is registered"] = function()
    vim.g.colors_name = "default"

    config.__register_colorscheme_initialization()

    expect.no_error(function()
        vim.api.nvim_get_hl(0, { name = constants.HIGHLIGHT_GROUPS.up_to_date })
        vim.api.nvim_get_hl(0, { name = constants.HIGHLIGHT_GROUPS.outdated })
    end)
end

T["should register colors if termguicolors is available"] = function()
    vim.o.termguicolors = true

    config.__register_colorscheme_initialization()

    local up_to_date_hl = vim.api.nvim_get_hl(0, { name = constants.HIGHLIGHT_GROUPS.up_to_date })
    local outdated_hl = vim.api.nvim_get_hl(0, { name = constants.HIGHLIGHT_GROUPS.outdated })

    local is_up_to_date_color_registered = up_to_date_hl.fg
        == tonumber(config.options.highlights.up_to_date.fg:gsub("#", ""), 16)
    local is_outdated_color_registered = outdated_hl.fg
        == tonumber(config.options.highlights.outdated.fg:gsub("#", ""), 16)

    expect.equality(is_outdated_color_registered, true)
    expect.equality(is_up_to_date_color_registered, true)
end

T["should register colors if termguicolors not available"] = function()
    vim.o.termguicolors = false

    config.__register_colorscheme_initialization()

    local up_to_date_hl = vim.api.nvim_get_hl(0, { name = constants.HIGHLIGHT_GROUPS.up_to_date })
    local outdated_hl = vim.api.nvim_get_hl(0, { name = constants.HIGHLIGHT_GROUPS.outdated })

    local is_up_to_date_color_registered = up_to_date_hl.ctermfg == config.options.highlights.up_to_date.ctermfg
    local is_outdated_color_registered = outdated_hl.ctermfg == config.options.highlights.outdated.ctermfg

    expect.equality(is_outdated_color_registered, true)
    expect.equality(is_up_to_date_color_registered, true)
end

return T
