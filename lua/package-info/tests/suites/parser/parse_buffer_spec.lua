local expect = MiniTest.expect

local core = require("package-info.core")
local parser = require("package-info.parser")
local state = require("package-info.state")
local clean_version = require("package-info.helpers.clean_version")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should map and set all dependencies to state"] = function()
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

    expect.equality(state.dependencies.installed, expected_dependency_list)
end

T["should flag dependencies with a templated version as invalid"] = function()
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

    expect.equality(invalid.react, nil)
    expect.equality(invalid.next.diagnostic, "INVALID VERSION")
end

T["should treat a null dependency block as empty"] = function()
    local package_json = file.create({
        name = "package.json",
        randomize = true,
        go = true,
        content = [[
                {
                    "name": "repo-name",
                    "dependencies": null,
                    "devDependencies": null
                }
            ]],
    })

    core.load_plugin()

    expect.no_error(parser.parse_buffer)

    local installed = state.dependencies.installed

    file.delete(package_json.path)

    expect.equality(installed, {})
end

T["should flag a dependency with a null version as invalid"] = function()
    local package_json = file.create({
        name = "package.json",
        randomize = true,
        go = true,
        content = [[
                {
                    "name": "repo-name",
                    "dependencies": {
                        "react": null,
                        "next": "12.0.3"
                    }
                }
            ]],
    })

    core.load_plugin()

    expect.no_error(parser.parse_buffer)

    local installed = state.dependencies.installed
    local invalid = state.dependencies.invalid

    file.delete(package_json.path)

    expect.equality(installed.react.current, nil)
    expect.equality(invalid.react.diagnostic, "INVALID VERSION")
    expect.equality(invalid.next, nil)
end

T["should not crash on a package.json that is not an object"] = function()
    local package_json = file.create({
        name = "package.json",
        randomize = true,
        go = true,
        content = "12",
    })

    core.load_plugin()

    expect.no_error(parser.parse_buffer)

    local installed = state.dependencies.installed
    local package_name = state.buffer.package_name

    file.delete(package_json.path)

    expect.equality(installed, {})
    expect.equality(package_name, nil)
end

T["should ignore a null package name"] = function()
    local package_json = file.create({
        name = "package.json",
        randomize = true,
        go = true,
        content = [[
                {
                    "name": null,
                    "dependencies": {
                        "react": "16.0.0"
                    }
                }
            ]],
    })

    core.load_plugin()
    parser.parse_buffer()

    local package_name = state.buffer.package_name

    file.delete(package_json.path)

    expect.equality(package_name, nil)
end

return T
