local expect = MiniTest.expect

local state = require("package-info.state")
local normalize_outdated = require("package-info.helpers.normalize_outdated")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should leave a single entry untouched"] = function()
    local outdated = normalize_outdated({
        react = { current = "16.0.0", wanted = "16.0.0", latest = "18.0.0", dependent = "repo-name" },
    })

    expect.equality(outdated.react.latest, "18.0.0")
end

T["should flatten a list of entries into the one matching the opened package.json"] = function()
    state.buffer.package_name = "website"

    local outdated = normalize_outdated({
        react = {
            { current = "16.0.0", wanted = "16.0.0", latest = "18.0.0", dependent = "api" },
            { current = "17.0.0", wanted = "17.0.0", latest = "18.0.0", dependent = "website" },
        },
    })

    expect.equality(outdated.react.latest, "18.0.0")
    expect.equality(outdated.react.dependent, "website")
end

T["should fall back to the first usable entry when no dependent matches"] = function()
    state.buffer.package_name = "unrelated"

    local outdated = normalize_outdated({
        react = {
            { current = "16.0.0", wanted = "16.0.0", latest = "18.0.0", dependent = "api" },
            { current = "17.0.0", wanted = "17.0.0", latest = "18.0.0", dependent = "website" },
        },
    })

    expect.equality(outdated.react.latest, "18.0.0")
    expect.equality(outdated.react.dependent, "api")
end

T["should drop a list with no usable entries"] = function()
    local outdated = normalize_outdated({ react = { {}, {} } })

    expect.equality(outdated.react, nil)
end

T["should drop a single entry without a latest version"] = function()
    local outdated = normalize_outdated({ react = { current = "16.0.0", wanted = "16.0.0" } })

    expect.equality(outdated.react, nil)
end

T["should return an empty table for a non table value"] = function()
    expect.equality(normalize_outdated(nil), {})
    expect.equality(normalize_outdated("error"), {})
end

return T
