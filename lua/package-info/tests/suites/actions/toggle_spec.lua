local expect = MiniTest.expect

local toggle_action = require("package-info").toggle
local config = require("package-info.config")
local core = require("package-info.core")
local virtual_text = require("package-info.virtual_text")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")
local spy = require("package-info.tests.utils.spy")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should not throw"] = function()
    file.create_package_json({ go = true })

    spy.on(virtual_text, "clear")
    spy.on(virtual_text, "display")

    config.setup()
    core.load_plugin()

    expect.no_error(function()
        toggle_action()
    end)
end

return T
