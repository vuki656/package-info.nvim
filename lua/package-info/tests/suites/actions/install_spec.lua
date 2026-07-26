local expect = MiniTest.expect

local config = require("package-info.config")
local install_action = require("package-info.actions.install")
local core = require("package-info.core")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should not throw on production dependency install"] = function()
    file.create_package_json({ go = true })

    config.setup()
    core.load_plugin()

    expect.no_error(function()
        install_action.run()

        vim.api.nvim_input("<CR>")
        vim.api.nvim_input("dayjs")
        vim.api.nvim_input("<CR>")
    end)
end

T["should not throw on development dependency install"] = function()
    file.create_package_json({ go = true })

    config.setup()
    core.load_plugin()

    expect.no_error(function()
        install_action.run()

        vim.api.nvim_input("j")
        vim.api.nvim_input("<CR>")
        vim.api.nvim_input("prettier")
        vim.api.nvim_input("<CR>")
    end)
end

return T
