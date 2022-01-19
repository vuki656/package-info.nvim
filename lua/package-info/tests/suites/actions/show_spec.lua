local config = require("package-info.config")
local show_action = require("package-info.actions.show")
local core = require("package-info.core")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")

describe("Actions show", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should not throw", function()
        file.create_package_json({ go = true })

        config.setup()
        core.load_plugin()

        assert.has_no.errors(function()
            show_action.run()
        end)
    end)
end)
