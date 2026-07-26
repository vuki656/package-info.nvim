local expect = MiniTest.expect

local state = require("package-info.state")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["update"] = MiniTest.new_set()

T["update"]["should update last run time"] = function()
    state.last_run.update()

    expect.no_equality(state.last_run.time, nil)
end

T["should_skip"] = MiniTest.new_set()

T["should_skip"]["should return false if there was no last run"] = function()
    state.last_run.time = nil

    local should_skip = state.last_run.should_skip()

    expect.equality(should_skip, false)
end

T["should_skip"]["should return true if there was a show action run within the past hour"] = function()
    state.last_run.update()

    local should_skip = state.last_run.should_skip()

    expect.equality(should_skip, true)
end

T["should_skip"]["should return false if there was no show action run within the past hour"] = function()
    local TWO_HOURS_IN_SECONDS = 7200

    state.last_run.time = os.time() - TWO_HOURS_IN_SECONDS

    local should_skip = state.last_run.should_skip()

    expect.equality(should_skip, false)
end

return T
