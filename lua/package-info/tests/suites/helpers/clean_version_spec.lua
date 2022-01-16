local clean_version = require("package-info.helpers.clean_version")

local reset = require("package-info.tests.utils.reset")

describe("Helpers clean_version", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should return cleaned version", function()
        local cleaned_version = clean_version("^1.0.0")

        assert.are.equals("1.0.0", cleaned_version)
    end)

    it("should return nil if falsy value passed in", function()
        local cleaned_version = clean_version(nil)

        assert.is_nil(cleaned_version)
    end)
end)
