local spy = require("luassert.spy")
local hide_action = require("package-info.actions.hide")

local config = require("package-info.config")
local core = require("package-info.core")
local virtual_text = require("package-info.virtual_text")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")

describe("Actions hide", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should call clear() if plugin is loaded", function()
        file.create_package_json({ go = true })

        spy.on(virtual_text, "clear")

        config.setup()
        core.load_plugin()

        hide_action.run()

        assert.spy(virtual_text.clear).was_called(1)
    end)

    it("should do nothing if plugin isn't loaded", function()
        file.create_package_json({ go = true })

        spy.on(virtual_text, "clear")

        hide_action.run()

        assert.spy(virtual_text.clear).was_called(0)
    end)
end)
