local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")
local virtual_text = require("package-info.virtual_text")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Virtual_text display", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should be called for each dependency in package.json", function()
        local package_json = file.create_package_json({ go = true })

        config.setup()
        core.load_plugin()

        spy.on(virtual_text, "__display_on_line")

        virtual_text.display()

        file.delete(package_json.path)

        assert.spy(virtual_text.__display_on_line).was_called(package_json.total_count)
        assert.is_true(state.is_virtual_text_displayed)
    end)
end)
