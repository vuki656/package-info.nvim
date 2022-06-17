local config = require("package-info.config")
local change_version_action = require("package-info.actions.change-version")
local core = require("package-info.core")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")

describe("Actions change_version", function()
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
            change_version_action.run()
        end)
    end)
end)
