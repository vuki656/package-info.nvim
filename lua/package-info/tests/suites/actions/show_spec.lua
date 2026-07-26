local expect = MiniTest.expect

local config = require("package-info.config")
local show_action = require("package-info.actions.show")
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
    file.create_package_json({ go = true })

    config.setup()
    core.load_plugin()

    expect.no_error(function()
        show_action.run()
    end)
end

return T
