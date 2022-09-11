local config = require("package-info.config")
local to_boolean = require("package-info.utils.to-boolean")

local reset = require("package-info.tests.utils.reset")

describe("Config register_autostart", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should register autostart if autostart option is true", function()
        config.options.autostart = true

        config.__register_autostart()

        local autocommands = vim.api.nvim_exec("autocmd BufEnter", true)

        local is_registered = to_boolean(string.find(autocommands, "lua require('package-info').show()", 0, true))

        assert.is_true(is_registered)
    end)

    it("shouldn't register autostart if autostart option is false", function()
        config.options.autostart = false

        config.__register_autostart()

        local autocommands = vim.api.nvim_exec("autocmd BufEnter", true)

        local is_registered = to_boolean(string.find(autocommands, "lua require('package-info').show()", 0, true))

        assert.is_false(is_registered)
    end)
end)
