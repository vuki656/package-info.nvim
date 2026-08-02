local expect = MiniTest.expect

local state = require("package-info.state")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should restore the values stored for the given path"] = function()
    local outdated = { react = { latest = "18.0.0" } }

    state.buffer.path = "/repo/packages/website/package.json"
    state.dependencies.outdated = outdated
    state.last_run.update()

    state.cache.save()

    state.cache.restore("/repo/packages/api/package.json")
    state.cache.restore("/repo/packages/website/package.json")

    expect.equality(state.dependencies.outdated, outdated)
    expect.no_equality(state.last_run.time, nil)
end

T["should clear the values when the path has nothing stored"] = function()
    state.buffer.path = "/repo/packages/website/package.json"
    state.dependencies.outdated = { react = { latest = "18.0.0" } }
    state.dependencies.pnpm_workspace = { catalog = { react = "18.0.0" } }
    state.last_run.update()

    state.cache.restore("/repo/packages/api/package.json")

    expect.equality(state.dependencies.outdated, {})
    expect.equality(state.dependencies.pnpm_workspace, {})
    expect.equality(state.last_run.time, nil)
end

T["should store nothing when no package.json is loaded"] = function()
    state.buffer.path = nil

    state.cache.save()

    expect.equality(state.cache.entries, {})
end

T["should drop every stored path when the last run is reset"] = function()
    state.buffer.path = "/repo/packages/website/package.json"
    state.last_run.update()

    state.cache.save()

    state.last_run.reset()

    expect.equality(state.cache.entries, {})
end

return T
