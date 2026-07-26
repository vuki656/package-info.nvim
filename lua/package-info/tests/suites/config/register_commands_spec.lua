local expect = MiniTest.expect

local constants = require("package-info.utils.constants")
local config = require("package-info.config")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should register commands"] = function()
    config.__register_commands()

    expect.no_error(function()
        for _, command in pairs(constants.COMMANDS) do
            vim.cmd(command)
        end
    end)
end

return T
