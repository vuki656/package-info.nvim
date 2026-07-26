local expect = MiniTest.expect

local constants = require("package-info.utils.constants")
local config = require("package-info.config")
local to_boolean = require("package-info.utils.to-boolean")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should register colors"] = function()
    vim.cmd('let g:colors_name="weird-theme"')

    config.__register_colorscheme_initialization()

    local autocommands = vim.api.nvim_exec("autocmd ColorScheme", true)

    local is_registered = to_boolean(
        string.find(autocommands, "lua require('package-info.config').__register_highlight_groups()", 0, true)
    )

    expect.equality(is_registered, true)
end

T["should register colors if default theme is registered"] = function()
    vim.cmd('let g:colors_name="default"')

    config.__register_colorscheme_initialization()

    expect.no_error(function()
        vim.cmd("highlight " .. constants.HIGHLIGHT_GROUPS.up_to_date)
        vim.cmd("highlight " .. constants.HIGHLIGHT_GROUPS.outdated)
    end)
end

T["should register colors if termguicolors is available"] = function()
    vim.cmd("set termguicolors")

    config.__register_colorscheme_initialization()

    local up_to_date_hl = vim.api.nvim_get_hl(0, { name = constants.HIGHLIGHT_GROUPS.up_to_date })
    local outdated_hl = vim.api.nvim_get_hl(0, { name = constants.HIGHLIGHT_GROUPS.outdated })

    local is_up_to_date_color_registered = up_to_date_hl.fg
        == tonumber(config.options.highlights.up_to_date.fg:gsub("#", ""), 16)
    local is_outdated_color_registered = outdated_hl.fg
        == tonumber(config.options.highlights.outdated.fg:gsub("#", ""), 16)

    expect.no_equality(is_outdated_color_registered, nil)
    expect.no_equality(is_up_to_date_color_registered, nil)
end

T["should register colors if termguicolors not available"] = function()
    vim.cmd("set notermguicolors")

    config.__register_colorscheme_initialization()

    local up_to_date_color = vim.api.nvim_exec("highlight " .. constants.HIGHLIGHT_GROUPS.up_to_date, true)
    local outdated_color = vim.api.nvim_exec("highlight " .. constants.HIGHLIGHT_GROUPS.outdated, true)

    local is_up_to_date_color_registered =
        string.find(up_to_date_color, config.options.highlights.up_to_date.ctermfg, 0, true)
    local is_outdated_color_registered =
        string.find(outdated_color, config.options.highlights.outdated.ctermfg, 0, true)

    expect.no_equality(is_outdated_color_registered, nil)
    expect.no_equality(is_up_to_date_color_registered, nil)
end

return T
