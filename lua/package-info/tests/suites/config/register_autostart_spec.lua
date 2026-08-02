local expect = MiniTest.expect

local config = require("package-info.config")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should register autostart if autostart option is true"] = function()
    config.options.autostart = true

    config.__register_autostart()

    local autocommands = vim.api.nvim_get_autocmds({ event = "BufEnter" })

    local is_registered = false

    for _, autocommand in ipairs(autocommands) do
        if autocommand.command == "lua require('package-info').show()" then
            is_registered = true
        end
    end

    expect.equality(is_registered, true)
end

T["shouldn't register autostart if autostart option is false"] = function()
    config.options.autostart = false

    config.__register_autostart()

    local autocommands = vim.api.nvim_get_autocmds({ event = "BufEnter" })

    local is_registered = false

    for _, autocommand in ipairs(autocommands) do
        if autocommand.command == "lua require('package-info').show()" then
            is_registered = true
        end
    end

    expect.equality(is_registered, false)
end

return T
