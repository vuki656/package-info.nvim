local core = require("package-info.core")

describe("Core", function()
    before_each(function() end)

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
end)
