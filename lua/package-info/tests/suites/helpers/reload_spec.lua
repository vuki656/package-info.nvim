local expect = MiniTest.expect

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")
local parser = require("package-info.parser")
local reload = require("package-info.helpers.reload")
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

T["should reload the buffer if it's package.json"] = function()
    local package_json = file.create_package_json({ go = true })

    local parse_buffer = spy.on(parser, "parse_buffer")

    core.load_plugin()
    reload()

    file.delete(package_json.path)

    expect.equality(parse_buffer.count, 2)
end

T["should reload the buffer and re-render virtual text if it's displayed and in package.json"] = function()
    state.is_virtual_text_displayed = true

    local package_json = file.create_package_json({ go = true })

    local parse_buffer = spy.on(parser, "parse_buffer")
    local display = spy.on(virtual_text, "display")
    local clear = spy.on(virtual_text, "clear")

    config.setup()
    core.load_plugin()
    reload()

    file.delete(package_json.path)

    expect.equality(display.count, 1)
    expect.equality(clear.count, 1)
    expect.equality(parse_buffer.count, 2)
end

return T
