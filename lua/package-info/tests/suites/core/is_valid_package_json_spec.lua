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
        local package_json = file.create_package_json({ go = true })

        local is_valid = core.__is_valid_package_json()

        file.delete(package_json.path)

        assert.is_true(is_valid)
    end)

    it("should return false if buffer empty", function()
        local is_valid = core.__is_valid_package_json()

        assert.is_false(is_valid)
    end)

    it("should return false if file not called package.json", function()
        local path = "some_random_file_that_is_dead.txt"

        file.create({
            name = path,
            go = true,
        })

        local is_valid = core.__is_valid_package_json()

        file.delete(path)

        assert.is_false(is_valid)
    end)

    it("should return false if json is invalid format", function()
        local package_json = file.create_package_json({
            content = '{ "name" = function () { }',
            go = true,
        })

        local is_valid = core.__is_valid_package_json()

        file.delete(package_json.path)

        assert.is_false(is_valid)
    end)
end)
