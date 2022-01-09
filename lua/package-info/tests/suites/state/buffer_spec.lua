local state = require("package-info.state")
local reset = require("package-info.tests.utils.reset")

describe("State buffer", function()
    before_each(function()
        reset.state()
    end)

    it("should save buffer id", function()
        state.buffer.save()

        assert.is_true(state.buffer.id ~= nil)
    end)
end)
