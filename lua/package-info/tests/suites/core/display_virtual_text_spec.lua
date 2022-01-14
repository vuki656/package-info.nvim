local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Core display_virtual_text", function()
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

        spy.on(core, "__set_virtual_text")

        core.display_virtual_text()

        assert.spy(core.__set_virtual_text).was_called(package_json.total_count)
        assert.is_true(state.displayed)

        file.delete_package_json()
    end)
end)
