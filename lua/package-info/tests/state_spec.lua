local state = require("package-info.state")

describe("State buffer", function()
    it("should save buffer id", function()
        state.buffer.save()

        assert.is_true(state.buffer.id ~= nil)
    end)
end)

describe("State last_run", function()
    it("should should update last run time", function()
        state.last_run.update()

        assert.is_true(state.last_run.time ~= nil)
    end)

    it("should_skip should return false if there was no last run", function()
        state.last_run.time = nil

        local should_skip = state.last_run.should_skip()

        assert.is_false(should_skip)
    end)

    it("should_skip should return true if there was a show action run within the past hour", function()
        state.last_run.update()

        local should_skip = state.last_run.should_skip()

        assert.is_true(should_skip)
    end)

    it("should_skip should return false if there was no show action run within the past hour", function()
        local TWO_HOURS_IN_SECONDS = 7200

        -- Simulate 2 hour passing
        state.last_run.time = os.time() - TWO_HOURS_IN_SECONDS

        local should_skip = state.last_run.should_skip()

        assert.is_false(should_skip)
    end)
end)
