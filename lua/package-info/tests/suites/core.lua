-- TODO: split into multiple files
-- TODO: figure out how to make the mocking for virtual text display more DRY
-- TODO: option passing to display_virtual_text is janky, see if it can be better in the core itself

local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")
local constants = require("package-info.utils.constants")
local logger = require("package-info.utils.logger")
local to_boolean = require("package-info.utils.to-boolean")

local file = require("package-info.tests.utils.file")

describe("Core", function()
    before_each(function()
        state.reset()
    end)

    describe("clear_virtual_text", function()
        it("shouldn't run if nothing is displayed", function()
            state.displayed = false

            spy.on(vim.api, "nvim_buf_clear_namespace")

            core.clear_virtual_text()

            assert.spy(vim.api.nvim_buf_clear_namespace).was_called(0)
        end)

        it("shouldn clear all existing virtual text", function()
            state.displayed = false

            local file_name = "package.json"

            file.create(
                file_name,
                [[
                {
                    "dependencies": {
                        "react": "16.0.0"
                    }
                }
                ]]
            )
            file.go(file_name)

            spy.on(vim.api, "nvim_buf_clear_namespace")

            config.setup()
            core.load_plugin()
            core.display_virtual_text()
            core.clear_virtual_text()

            local virtual_text_positions = vim.api.nvim_buf_get_extmarks(state.buffer.id, state.namespace.id, 0, -1, {})

            assert.spy(vim.api.nvim_buf_clear_namespace).was_called(1)
            assert.is_true(vim.tbl_isempty(virtual_text_positions))

            file.delete(file_name)
        end)
    end)
end)
