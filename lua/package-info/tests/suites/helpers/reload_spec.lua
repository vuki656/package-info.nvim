local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")
local parser = require("package-info.parser")
local reload = require("package-info.helpers.reload")
local virtual_text = require("package-info.virtual_text")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")

describe("Helpers reload", function()
    before_each(function()
        reset.all()
    end)

    before_each(function()
        reset.all()
    end)

    it("should reload the buffer if it's package.json", function()
        local package_json = file.create_package_json({ go = true })

        spy.on(parser, "parse_buffer")

        core.load_plugin()
        reload()

        file.delete(package_json.path)

        assert.spy(parser.parse_buffer).was_called(2)
    end)

    it("should reload the buffer and re-render virtual text if it's displayed and in package.json", function()
        state.is_virtual_text_displayed = true

        local package_json = file.create_package_json({ go = true })

        spy.on(parser, "parse_buffer")
        spy.on(virtual_text, "display")
        spy.on(virtual_text, "clear")

        config.setup()
        core.load_plugin()
        reload()

        file.delete(package_json.path)

        assert.spy(virtual_text.display).was_called(1)
        assert.spy(virtual_text.clear).was_called(1)
        assert.spy(parser.parse_buffer).was_called(2)
    end)
end)
