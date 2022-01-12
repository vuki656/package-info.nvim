local core = require("package-info.core")

local reset = require("package-info.tests.utils.reset")

describe("Core is_valid_package_version", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should return true if version is valid", function()
        local is_valid = core.__is_valid_package_version("1.0.0")

        assert.is_true(is_valid)
    end)

    it("should return false if version is invalid", function()
        local is_valid = core.__is_valid_package_version("test")

        assert.is_false(is_valid)
    end)
end)
