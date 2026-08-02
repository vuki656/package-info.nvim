local expect = MiniTest.expect

local config = require("package-info.config")
local change_version_action = require("package-info.actions.change-version")
local core = require("package-info.core")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should not throw"] = function()
    local package_json = file.create_package_json({ go = true })

    config.setup()
    core.load_plugin()

    vim.api.nvim_win_set_cursor(0, { package_json.dependencies.eslint.position, 0 })

    expect.no_error(function()
        change_version_action.run()
    end)
end

return T
