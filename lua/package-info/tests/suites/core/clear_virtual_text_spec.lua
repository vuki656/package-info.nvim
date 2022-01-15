local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Core clear_virtual_text", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("shouldn't run if nothing is displayed", function()
        spy.on(vim.api, "nvim_buf_clear_namespace")

        core.clear_virtual_text()

        assert.spy(vim.api.nvim_buf_clear_namespace).was_called(0)
    end)

    it("should clear all existing virtual text", function()
        file.create_package_json({ go = true })

        spy.on(vim.api, "nvim_buf_clear_namespace")

        config.setup()
        core.load_plugin()
        core.display_virtual_text()
        core.clear_virtual_text()

        local virtual_text_positions = vim.api.nvim_buf_get_extmarks(state.buffer.id, state.namespace.id, 0, -1, {})

        file.delete_package_json()

        assert.spy(vim.api.nvim_buf_clear_namespace).was_called(1)
        assert.is_true(vim.tbl_isempty(virtual_text_positions))
    end)
end)
