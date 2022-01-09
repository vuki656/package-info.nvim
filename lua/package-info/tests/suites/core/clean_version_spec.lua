local core = require("package-info.core")

describe("Core clean_version", function()
    it("should return cleaned version", function()
        local cleaned_version = core.__clean_version("^1.0.0")

        assert.are.equals("1.0.0", cleaned_version)
    end)

    it("should return nil if falsy value passed in", function()
        local cleaned_version = core.__clean_version(nil)

        assert.is_nil(cleaned_version)
    end)
end)
