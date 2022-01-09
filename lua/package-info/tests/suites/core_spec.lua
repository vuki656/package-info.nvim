local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")

local file = require("package-info.tests.utils.file")

describe("Core", function()
    before_each(function()
        state.reset()
    end)

    describe("clean_version", function()
        it("should return cleaned version", function()
            local cleaned_version = core.__clean_version("^1.0.0")

            assert.are.equals("1.0.0", cleaned_version)
        end)

        it("should return nil if falsy value passed in", function()
            local cleaned_version = core.__clean_version(nil)

            assert.is_nil(cleaned_version)
        end)
    end)

    describe("is_valid_package_version", function()
        it("should return true if version is valid", function()
            local is_valid = core.__is_valid_package_version("1.0.0")

            assert.is_true(is_valid)
        end)

        it("should return false if version is invalid", function()
            local is_valid = core.__is_valid_package_version("test")

            assert.is_false(is_valid)
        end)
    end)

    describe("decode_json_string", function()
        it("should return nil if json is invalid", function()
            local json_value = core.__decode_json_string('{ l "name": "test" }')

            assert.is_nil(json_value)
        end)

        it("should decoded json if json is valid", function()
            local json_value = core.__decode_json_string('{ "name": "test" }')

            assert.are.same({ name = "test" }, json_value)
        end)
    end)

    describe("reload_buffer", function()
        it("should reload the buffer if it's package.json", function()
            local file_name = "package.json"

            file.create(file_name, '{ "name": "package" }')
            file.go(file_name)

            spy.on(vim, "cmd")
            spy.on(vim.fn, "winsaveview")
            spy.on(vim.fn, "winrestview")

            core.load_plugin()
            core.__reload_buffer()

            file.delete(file_name)

            assert.spy(vim.cmd).was_called(1)
            assert.spy(vim.cmd).was_called_with("edit")
            assert.spy(vim.fn.winsaveview).was_called(1)
            assert.spy(vim.fn.winrestview).was_called(1)
        end)

        it("shouldn't reload the buffer if it's not in package.json", function()
            spy.on(vim, "cmd")
            spy.on(vim.fn, "winsaveview")
            spy.on(vim.fn, "winrestview")

            core.load_plugin()
            core.__reload_buffer()

            assert.spy(vim.cmd).was_called(0)
            assert.spy(vim.fn.winsaveview).was_called(0)
            assert.spy(vim.fn.winrestview).was_called(0)
        end)
    end)
end)
