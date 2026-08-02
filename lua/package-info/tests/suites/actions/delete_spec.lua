local expect = MiniTest.expect

local config = require("package-info.config")
local delete_action = require("package-info.actions.delete")
local core = require("package-info.core")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should not throw on confirm"] = function()
    local package_json = file.create_package_json({ go = true })

    config.setup()
    core.load_plugin()

    vim.api.nvim_win_set_cursor(0, { package_json.dependencies.eslint.position, 0 })

    expect.no_error(function()
        delete_action.run()

        vim.api.nvim_input("<CR>")
    end)
end

T["should not throw on cancel"] = function()
    local package_json = file.create_package_json({ go = true })

    config.setup()
    core.load_plugin()

    vim.api.nvim_win_set_cursor(0, { package_json.dependencies.eslint.position, 0 })

    expect.no_error(function()
        delete_action.run()

        vim.api.nvim_input("<CR>j")
    end)
end

return T
