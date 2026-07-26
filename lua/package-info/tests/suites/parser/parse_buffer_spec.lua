local core = require("package-info.core")
local parser = require("package-info.parser")
local state = require("package-info.state")
local clean_version = require("package-info.helpers.clean_version")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Parser parse_buffer", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should map and set all dependencies to state", function()
        local package_json = file.create_package_json({ go = true })

        core.load_plugin()
        parser.parse_buffer()

        local expected_dependency_list = {}

        for _, dependency in pairs(package_json.dependencies) do
            expected_dependency_list[dependency.name] = {
                current = clean_version(dependency.version.current),
            }
        end

        file.delete(package_json.path)

        assert.are.same(expected_dependency_list, state.dependencies.installed)
    end)

    it("should flag dependencies with a templated version as invalid", function()
        local package_json = file.create({
            name = "package.json",
            randomize = true,
            go = true,
            content = [[
                {
                    "name": "repo-name",
                    "dependencies": {
                        "react": "16.0.0",
                        "next": "^12.0.3<% if (typescript) { %>"
                    }
                }
            ]],
        })

        core.load_plugin()
        parser.parse_buffer()

        local invalid = state.dependencies.invalid

        file.delete(package_json.path)

        assert.are.equals(nil, invalid.react)
        assert.are.equals("INVALID VERSION", invalid.next.diagnostic)
    end)
end)
