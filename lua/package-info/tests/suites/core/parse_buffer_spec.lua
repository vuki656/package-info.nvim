local core = require("package-info.core")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Core parse_buffer", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should map and set all dependencies to state", function()
        local package_json = file.create_package_json({ go = true })

        core.load_plugin()
        core.parse_buffer()

        local expected_dependency_list = {}

        for _, dependency in pairs(package_json.dependencies) do
            expected_dependency_list[dependency.name] = {
                version = {
                    current = core.__clean_version(dependency.version.current),
                },
            }
        end

        assert.are.same(core.__dependencies, expected_dependency_list)

        file.delete_package_json()
    end)
end)
