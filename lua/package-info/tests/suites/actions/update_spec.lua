local config = require("package-info.config")
local update_action = require("package-info.actions.update")
local core = require("package-info.core")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")

describe("Actions update", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should not throw", function()
        local package_json = file.create_package_json({ go = true })

        config.setup()
        core.load_plugin()

        vim.cmd(tostring(package_json.dependencies.eslint.position))

        assert.has_no.errors(function()
            update_action.run()
        end)
    end)
end)
