local state = require("package-info.state")
local reset = require("package-info.tests.utils.reset")

describe("State buffer", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should save buffer id", function()
        state.buffer.save()

        assert.is_not_nil(state.buffer.id)
    end)
end)
