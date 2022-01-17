local config = require("package-info.config")
local delete_action = require("package-info.actions.delete")
local core = require("package-info.core")

local reset = require("package-info.tests.utils.reset")
local file = require("package-info.tests.utils.file")

describe("Actions delete", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should not throw on confirm", function()
        local package_json = file.create_package_json({ go = true })

        config.setup()
        core.load_plugin()

        vim.cmd(tostring(package_json.dependencies.eslint.position))

        assert.has_no.errors(function()
            delete_action.run()

            vim.api.nvim_input("<CR>")
        end)
    end)

    it("should not throw on cancel", function()
        local package_json = file.create_package_json({ go = true })

        config.setup()
        core.load_plugin()

        vim.cmd(tostring(package_json.dependencies.eslint.position))

        assert.has_no.errors(function()
            delete_action.run()

            vim.api.nvim_input("<CR>j")
        end)
    end)
end)
