local expect = MiniTest.expect

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")
local virtual_text = require("package-info.virtual_text")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")
local spy = require("package-info.tests.utils.spy")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should be called for each dependency in package.json"] = function()
    local package_json = file.create_package_json({ go = true })

    config.setup()
    core.load_plugin()

    local display_on_line = spy.on(virtual_text, "__display_on_line")

    virtual_text.display()

    file.delete(package_json.path)

    expect.equality(display_on_line.count, package_json.total_count)
    expect.equality(state.is_virtual_text_displayed, true)
end

return T
