local expect = MiniTest.expect

local config = require("package-info.config")
local to_boolean = require("package-info.utils.to-boolean")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should register load command"] = function()
    config.__register_start()

    local autocommands = vim.api.nvim_exec("autocmd BufEnter", true)

    local is_registered = to_boolean(string.find(autocommands, "require('package-info.core').load_plugin()", 0, true))

    expect.equality(is_registered, true)
end

return T
