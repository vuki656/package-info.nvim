local state = require("package-info.state")
local normalize_outdated = require("package-info.helpers.normalize_outdated")

local reset = require("package-info.tests.utils.reset")

describe("Normalize_outdated", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should leave a single entry untouched", function()
        local outdated = normalize_outdated({
            react = { current = "16.0.0", wanted = "16.0.0", latest = "18.0.0", dependent = "repo-name" },
        })

        assert.are.equals("18.0.0", outdated.react.latest)
    end)

    it("should flatten a list of entries into the one matching the opened package.json", function()
        state.buffer.package_name = "website"

        local outdated = normalize_outdated({
            react = {
                { current = "16.0.0", wanted = "16.0.0", latest = "18.0.0", dependent = "api" },
                { current = "17.0.0", wanted = "17.0.0", latest = "18.0.0", dependent = "website" },
            },
        })

        assert.are.equals("18.0.0", outdated.react.latest)
        assert.are.equals("website", outdated.react.dependent)
    end)

    it("should fall back to the first usable entry when no dependent matches", function()
        state.buffer.package_name = "unrelated"

        local outdated = normalize_outdated({
            react = {
                { current = "16.0.0", wanted = "16.0.0", latest = "18.0.0", dependent = "api" },
                { current = "17.0.0", wanted = "17.0.0", latest = "18.0.0", dependent = "website" },
            },
        })

        assert.are.equals("18.0.0", outdated.react.latest)
        assert.are.equals("api", outdated.react.dependent)
    end)

    it("should drop a list with no usable entries", function()
        local outdated = normalize_outdated({ react = { {}, {} } })

        assert.are.equals(nil, outdated.react)
    end)

    it("should drop a single entry without a latest version", function()
        local outdated = normalize_outdated({ react = { current = "16.0.0", wanted = "16.0.0" } })

        assert.are.equals(nil, outdated.react)
    end)

    it("should return an empty table for a non table value", function()
        assert.are.same({}, normalize_outdated(nil))
        assert.are.same({}, normalize_outdated("error"))
    end)
end)
