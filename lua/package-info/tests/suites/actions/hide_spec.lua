local expect = MiniTest.expect

local hide_action = require("package-info.actions.hide")
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

T["should call clear() if plugin is loaded"] = function()
    file.create_package_json({ go = true })

    local clear = spy.on(virtual_text, "clear")

    config.setup()
    core.load_plugin()

    hide_action.run()

    expect.equality(clear.count, 1)
end

T["should do nothing if plugin isn't loaded"] = function()
    file.create_package_json({ go = true })

    local clear = spy.on(virtual_text, "clear")

    hide_action.run()

    expect.equality(clear.count, 0)
end

return T
