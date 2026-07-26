local expect = MiniTest.expect

local is_on_disk = require("package-info.helpers.is_on_disk")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should return true for an existing file"] = function()
    local package_json = file.create_package_json({})

    local result = is_on_disk(package_json.path)

    file.delete(package_json.path)

    expect.equality(result, true)
end

T["should return false for a path in a non existing directory"] = function()
    expect.equality(is_on_disk("./temp/this-directory-does-not-exist/package.json"), false)
end

T["should return false for uri style buffer names"] = function()
    expect.equality(is_on_disk("diffview:///home/user/project/.git/abc123/package.json"), false)
    expect.equality(is_on_disk("fugitive:///home/user/project/.git//abc123/package.json"), false)
    expect.equality(is_on_disk("octo://vuki656/package-info.nvim/pull/1/file/package.json"), false)
    expect.equality(is_on_disk("zipfile:///home/user/project.zip::package.json"), false)
end

T["should return false for an empty path"] = function()
    expect.equality(is_on_disk(""), false)
    expect.equality(is_on_disk(nil), false)
end

return T
