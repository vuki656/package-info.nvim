local constants = require("package-info.utils.constants")
local config = require("package-info.config")
local state = require("package-info.state")

describe("Config", function()
    local default_options = config.options

    before_each(function()
        -- Reset options to default ones
        config.options = default_options
    end)

    describe("register_autostart", function()
        it("should register autostart if autostart option is true", function()
            vim.cmd("autocmd! " .. constants.AUTOGROUP)

            config.__register_autostart()

            local autocommands = vim.api.nvim_exec("autocmd BufEnter", true)

            local is_registered = string.find(autocommands, "lua require('package-info').show()", 0, true)

            assert.is_true(is_registered ~= nil)
        end)

        it("shouldn't register autostart if autostart option is false", function()
            vim.cmd("autocmd! " .. constants.AUTOGROUP)

            config.__register_user_options({ autostart = false })
            config.__register_autostart()

            local autocommands = vim.api.nvim_exec("autocmd BufEnter", true)

            local is_registered = string.find(autocommands, "lua require('package-info').show()", 0, true)

            assert.is_true(is_registered == nil)
        end)
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
