local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")
local parser = require("package-info.parser")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")

describe("Core reload", function()
    before_each(function()
        reset.all()
    end)

    before_each(function()
        reset.all()
    end)

    it("should reload the buffer if it's package.json", function()
        local package_json = file.create_package_json({ go = true })

        spy.on(core, "__reload_buffer")
        spy.on(parser, "parse_buffer")

        core.load_plugin()
        core.reload()

        file.delete(package_json.path)

        assert.spy(core.__reload_buffer).was_called(2)
        assert.spy(parser.parse_buffer).was_called(2)
    end)

    it("should reload the buffer and re-render virtual text if it's displayed and in package.json", function()
        state.virtual_text.is_displayed = true

        local package_json = file.create_package_json({ go = true })

        spy.on(core, "__reload_buffer")
        spy.on(core, "display_virtual_text")
        spy.on(parser, "parse_buffer")
        spy.on(state.virtual_text, "clear")

        config.setup()
        core.load_plugin()
        core.reload()

        file.delete(package_json.path)

        assert.spy(core.__reload_buffer).was_called(2)
        assert.spy(core.display_virtual_text).was_called(1)
        assert.spy(parser.parse_buffer).was_called(2)
        assert.spy(state.virtual_text.clear).was_called(1)
    end)
end)
