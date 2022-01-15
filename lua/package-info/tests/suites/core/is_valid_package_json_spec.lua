local core = require("package-info.core")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Core is_valid_package_json", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should return true for valid package.json", function()
        file.create_package_json({ go = true })

        local is_valid = core.is_valid_package_json()

        file.delete_package_json()

        assert.is_true(is_valid)

        file.delete_package_json()
    end)

    it("should return false if buffer empty", function()
        local is_valid = core.is_valid_package_json()

        assert.is_false(is_valid)
    end)

    it("should return false if file not called package.json", function()
        local path = "test.txt"

        file.create({ path = path })
        file.go(path)

        local is_valid = core.is_valid_package_json()

        file.delete(path)

        assert.is_false(is_valid)
    end)

    -- it("should return false json is invalid format", function()
    --     -- TODO: implement when core:201 is solved
    -- end)
end)
