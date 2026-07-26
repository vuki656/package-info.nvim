local expect = MiniTest.expect

local config = require("package-info.config")
local state = require("package-info.state")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should register namespace"] = function()
    config.__register_namespace()

    expect.no_equality(state.namespace.id, nil)
    expect.equality(vim.api.nvim_get_namespaces()["package-info"], state.namespace.id)
end

return T
