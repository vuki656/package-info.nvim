local expect = MiniTest.expect

local is_valid_version_syntax = require("package-info.helpers.is_valid_version_syntax")

local T = MiniTest.new_set()

T["should accept plain versions"] = function()
    expect.equality(is_valid_version_syntax("1.0.0"), true)
    expect.equality(is_valid_version_syntax("^1.0.0"), true)
    expect.equality(is_valid_version_syntax("~1.0.0"), true)
    expect.equality(is_valid_version_syntax("1.0.0-beta.1"), true)
    expect.equality(is_valid_version_syntax("1.0.0+build.5"), true)
end

T["should accept ranges and tags"] = function()
    expect.equality(is_valid_version_syntax("*"), true)
    expect.equality(is_valid_version_syntax("latest"), true)
    expect.equality(is_valid_version_syntax(">=1.0.0"), true)
    expect.equality(is_valid_version_syntax("1.0.0 - 2.0.0"), true)
    expect.equality(is_valid_version_syntax("1.0.0 || 2.0.0"), true)
end

T["should accept protocol based versions"] = function()
    expect.equality(is_valid_version_syntax("catalog:"), true)
    expect.equality(is_valid_version_syntax("catalog:frontend"), true)
    expect.equality(is_valid_version_syntax("workspace:*"), true)
    expect.equality(is_valid_version_syntax("npm:react@1.0.0"), true)
    expect.equality(is_valid_version_syntax("file:../react"), true)
    expect.equality(is_valid_version_syntax("git+ssh://git@github.com/user/repo.git#v1.0.0"), true)
end

T["should reject templated versions"] = function()
    expect.equality(is_valid_version_syntax("^1.0.0<% if (typescript) { %>"), false)
    expect.equality(is_valid_version_syntax("1.0.0<% } %>"), false)
    expect.equality(is_valid_version_syntax("{{version}}"), false)
end

return T
