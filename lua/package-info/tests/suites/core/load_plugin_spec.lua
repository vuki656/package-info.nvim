local expect = MiniTest.expect

local core = require("package-info.core")
local state = require("package-info.state")
local parser = require("package-info.parser")
local to_boolean = require("package-info.utils.to-boolean")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")
local spy = require("package-info.tests.utils.spy")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should return nil if not in package.json"] = function()
    local is_loaded = to_boolean(core.load_plugin())

    expect.equality(is_loaded, false)
end

T["should load the plugin if in package.json"] = function()
    local package_json = file.create_package_json({ go = true })

    local parse_buffer = spy.on(parser, "parse_buffer")
    local save = spy.on(state.buffer, "save")

    core.load_plugin()

    file.delete(package_json.path)

    expect.equality(save.count, 1)
    expect.equality(parse_buffer.count, 1)
end

return T
