local expect = MiniTest.expect

local state = require("package-info.state")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should save buffer id"] = function()
    state.buffer.save()

    expect.no_equality(state.buffer.id, nil)
end

return T
