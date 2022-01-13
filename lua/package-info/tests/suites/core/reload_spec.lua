local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")

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
        file.create_package_json({ go = true })

        spy.on(core, "__reload_buffer")
        spy.on(core, "parse_buffer")

        core.load_plugin()
        core.reload()

        assert.spy(core.__reload_buffer).was_called(2)
        assert.spy(core.parse_buffer).was_called(2)

        file.delete_package_json()
    end)

    it("should reload the buffer and re-render virtual text if it's displayed and in package.json", function()
        state.displayed = true

        file.create_package_json({ go = true })

        spy.on(core, "__reload_buffer")
        spy.on(core, "parse_buffer")
        spy.on(core, "clear_virtual_text")
        spy.on(core, "display_virtual_text")

        config.setup()
        core.load_plugin()
        core.reload()

        assert.spy(core.__reload_buffer).was_called(2)
        assert.spy(core.parse_buffer).was_called(2)
        assert.spy(core.clear_virtual_text).was_called(1)
        assert.spy(core.display_virtual_text).was_called(1)

        file.delete_package_json()
    end)
end)
