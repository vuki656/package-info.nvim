local expect = MiniTest.expect

local core = require("package-info.core")
local state = require("package-info.state")
local parser = require("package-info.parser")
local to_boolean = require("package-info.utils.to-boolean")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")
local spy = require("package-info.tests.utils.spy")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should return nil if not in package.json"] = function()
    local is_loaded = to_boolean(core.load_plugin())

    expect.equality(is_loaded, false)
end

T["should load the plugin if in package.json"] = function()
    local package_json = file.create_package_json({ go = true })

    local parse_buffer = spy.on(parser, "parse_buffer")
    local save = spy.on(state.buffer, "save")

    core.load_plugin()

    file.delete(package_json.path)

    expect.equality(save.count, 1)
    expect.equality(parse_buffer.count, 1)
end

T["should drop the outdated dependencies of the previously loaded package.json"] = function()
    local first_package_json = file.create_package_json({ go = true })

    core.load_plugin()

    state.dependencies.outdated = { react = { latest = "18.0.0" } }
    state.last_run.update()

    local second_package_json = file.create_package_json({ go = true })

    core.load_plugin()

    file.delete(first_package_json.path)
    file.delete(second_package_json.path)

    expect.equality(state.dependencies.outdated, {})
    expect.equality(state.last_run.time, nil)
end

T["should restore the outdated dependencies when going back to a package.json"] = function()
    local first_package_json = file.create_package_json({ go = true })

    core.load_plugin()

    local outdated = { react = { latest = "18.0.0" } }

    state.dependencies.outdated = outdated
    state.last_run.update()

    local second_package_json = file.create_package_json({ go = true })

    core.load_plugin()

    file.go(first_package_json.path)

    core.load_plugin()

    file.delete(first_package_json.path)
    file.delete(second_package_json.path)

    expect.equality(state.dependencies.outdated, outdated)
    expect.no_equality(state.last_run.time, nil)
end

T["should keep the outdated dependencies of the same package.json"] = function()
    local package_json = file.create_package_json({ go = true })

    core.load_plugin()

    local outdated = { react = { latest = "18.0.0" } }

    state.dependencies.outdated = outdated
    state.last_run.update()

    core.load_plugin()

    file.delete(package_json.path)

    expect.equality(state.dependencies.outdated, outdated)
    expect.no_equality(state.last_run.time, nil)
end

return T
