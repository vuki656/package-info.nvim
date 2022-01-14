local spy = require("luassert.spy")

local core = require("package-info.core")
local logger = require("package-info.utils.logger")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Core get_dependency_name_from_current_line", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should get the name correctly", function()
        local package_json = file.create_package_json({ go = true })

        core.load_plugin()

        vim.cmd(tostring(package_json.dependencies.eslint.position))

        local dependency_name = core.get_dependency_name_from_current_line()

        assert.are.equals(package_json.dependencies.eslint.name, dependency_name)

        file.delete_package_json()
    end)

    it("should return nil if no valid dependency is on the current line", function()
        file.create_package_json({ go = true })

        core.load_plugin()

        spy.on(logger, "warn")

        vim.cmd("999")

        local dependency_name = core.get_dependency_name_from_current_line()

        assert.is_nil(dependency_name)
        assert.spy(logger.warn).was_called(1)
        assert.spy(logger.warn).was_called_with("No valid package on current line")

        file.delete_package_json()
    end)
end)
