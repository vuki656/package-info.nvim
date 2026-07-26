local expect = MiniTest.expect

local clean_version = require("package-info.helpers.clean_version")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should return cleaned version"] = function()
    local cleaned_version = clean_version("^1.0.0")

    expect.equality(cleaned_version, "1.0.0")
end

T["should return nil if falsy value passed in"] = function()
    local cleaned_version = clean_version(nil)

    expect.equality(cleaned_version, nil)
end

return T
