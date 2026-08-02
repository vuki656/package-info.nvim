local expect = MiniTest.expect

local config = require("package-info.config")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should register load command"] = function()
    config.__register_start()

    local autocommands = vim.api.nvim_get_autocmds({ event = "BufEnter" })

    local is_registered = false

    for _, autocommand in ipairs(autocommands) do
        if autocommand.command == "lua require('package-info.core').load_plugin()" then
            is_registered = true
        end
    end

    expect.equality(is_registered, true)
end

return T
