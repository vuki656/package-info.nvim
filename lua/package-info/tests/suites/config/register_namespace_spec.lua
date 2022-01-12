local config = require("package-info.config")
local state = require("package-info.state")

local reset = require("package-info.tests.utils.reset")

describe("Config register_namespace", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should register namespace", function()
        config.__register_namespace()

        assert.are.equals(1, state.namespace.id)
    end)
end)
