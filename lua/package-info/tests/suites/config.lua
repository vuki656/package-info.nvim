local constants = require("package-info.utils.constants")
local config = require("package-info.config")
local state = require("package-info.state")

describe("Config", function()
    local default_options = config.options

    before_each(function()
        -- Reset options to default ones
        config.options = default_options
    end)

    describe("register_commands", function()
        it("should register commands", function()
            config.__register_commands()

            assert.has_no.errors(function()
                for _, command in pairs(constants.COMMANDS) do
                    vim.cmd(command)
                end
            end)
        end)
    end)
end)
