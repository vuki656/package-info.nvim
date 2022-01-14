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

    describe("display_virtual_text", function()
        it("should be called for each dependency in package.json", function()
            local file_name = "package.json"

            file.create(
                file_name,
                [[
                {
                    "dependencies": {
                        "react": "16.0.0",
                        "nextjs": "12.1.1"
                    }
                }
                ]]
            )
            file.go(file_name)

            config.setup()
            core.load_plugin()

            spy.on(core, "__set_virtual_text")

            core.reload()

            assert.is_true(state.displayed)
            assert.spy(core.__set_virtual_text).was_called(2)

            file.delete(file_name)
        end)
    end)

    describe("is_valid_package_json", function()
        it("should return true for valid package.json", function()
            local file_name = "package.json"

            file.create(
                file_name,
                [[
                {
                    "dependencies": {
                        "react": "16.0.0",
                        "nextjs": "12.1.1"
                    }
                }
                ]]
            )
            file.go(file_name)

            config.setup()

            spy.on(state.buffer, "save")

            local is_valid = core.is_valid_package_json()

            assert.is_true(is_valid)
            assert.spy(state.buffer.save).was_called(1)
            assert.is_not_nil(state.buffer.id)

            file.delete(file_name)
        end)

        it("should return false if buffer empty", function()
            local file_name = "package.json"

            file.create(file_name, nil)
            file.go(file_name)

            config.setup()

            spy.on(state.buffer, "save")

            local is_valid = core.is_valid_package_json()

            assert.is_false(is_valid)
            assert.spy(state.buffer.save).was_called(0)
            assert.is_nil(state.buffer.id)

            file.delete(file_name)
        end)

        it("should return false if file not called package.json", function()
            local file_name = "test.txt"

            file.create(file_name, nil)
            file.go(file_name)

            config.setup()

            spy.on(state.buffer, "save")

            local is_valid = core.is_valid_package_json()

            assert.is_false(is_valid)
            assert.spy(state.buffer.save).was_called(0)
            assert.is_nil(state.buffer.id)

            file.delete(file_name)
        end)

        it("should return false json is invalid format", function()
            -- TODO: implement when core:201 is solved
        end)

        it("should return false if buffer is empty", function()
            local file_name = "package.json"

            file.create(file_name, nil)
            file.go(file_name)

            config.setup()

            spy.on(state.buffer, "save")

            local is_valid = core.is_valid_package_json()

            assert.is_false(is_valid)
            assert.spy(state.buffer.save).was_called(0)
            assert.is_nil(state.buffer.id)

            file.delete(file_name)
        end)
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
