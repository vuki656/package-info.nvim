local is_on_disk = require("package-info.helpers.is_on_disk")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Helpers is_on_disk", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should return true for an existing file", function()
        local package_json = file.create_package_json({})

        local result = is_on_disk(package_json.path)

        file.delete(package_json.path)

        assert.is_true(result)
    end)

    it("should return false for a path in a non existing directory", function()
        assert.is_false(is_on_disk("./temp/this-directory-does-not-exist/package.json"))
    end)

    it("should return false for uri style buffer names", function()
        assert.is_false(is_on_disk("diffview:///home/user/project/.git/abc123/package.json"))
        assert.is_false(is_on_disk("fugitive:///home/user/project/.git//abc123/package.json"))
        assert.is_false(is_on_disk("octo://vuki656/package-info.nvim/pull/1/file/package.json"))
        assert.is_false(is_on_disk("zipfile:///home/user/project.zip::package.json"))
    end)

    it("should return false for an empty path", function()
        assert.is_false(is_on_disk(""))
        assert.is_false(is_on_disk(nil))
    end)
end)
