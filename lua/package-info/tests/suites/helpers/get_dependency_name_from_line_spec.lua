local core = require("package-info.core")
local get_dependency_name_from_line = require("package-info.helpers.get_dependency_name_from_line")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Helpers get_dependency_name_from_line", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should return nil if line is not in correct format", function()
        local dependency_name = get_dependency_name_from_line('"react = "1.2.2"')

        assert.is_nil(dependency_name)
    end)

    it("should return nil if version not in the correct format", function()
        local dependency_name = get_dependency_name_from_line('"react": "10s,s.0"')

        assert.is_nil(dependency_name)
    end)

    it("should return nil if dependency not on the list", function()
        local package_json = file.create_package_json({ go = true })

        core.load_plugin()

        local dependency_name = get_dependency_name_from_line('"dep_that_does_not_exist": "1.0.0"')

        file.delete(package_json.path)

        assert.is_nil(dependency_name)
    end)

    it("should return dependency name if line is valid and dependency is in package.json", function()
        local package_json = file.create_package_json({ go = true })

        core.load_plugin()

        local dependency_name = get_dependency_name_from_line(
            string.format(
                '"%s": "%s"',
                package_json.dependencies.react.name,
                package_json.dependencies.react.version.current
            )
        )

        file.delete(package_json.path)

        assert.are.equals(package_json.dependencies.react.name, dependency_name)
    end)
end)
