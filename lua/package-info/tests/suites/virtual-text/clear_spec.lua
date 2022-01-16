local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")
local virtual_text = require("package-info.virtual_text")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Virtual_text display", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("shouldn't run if virtual text is not displayed", function()
        spy.on(vim.api, "nvim_buf_clear_namespace")

        virtual_text.clear()

        assert.spy(vim.api.nvim_buf_clear_namespace).was_called(0)
    end)

    it("should clear all existing virtual text", function()
        local package_json = file.create_package_json({ go = true })

        spy.on(vim.api, "nvim_buf_clear_namespace")

        config.setup()
        core.load_plugin()
        virtual_text.display()
        virtual_text.clear()

        local virtual_text_positions = vim.api.nvim_buf_get_extmarks(state.buffer.id, state.namespace.id, 0, -1, {})

        file.delete(package_json.path)

        assert.spy(vim.api.nvim_buf_clear_namespace).was_called(1)
        assert.is_true(vim.tbl_isempty(virtual_text_positions))
    end)
end)
