local state = require("package-info.state")
local reset = require("package-info.tests.utils.reset")

describe("State last_run", function()
    describe("update", function()
        before_each(function()
            reset.all()
        end)

        after_each(function()
            reset.all()
        end)

        it("should update last run time", function()
            state.last_run.update()

            assert.is_true(state.last_run.time ~= nil)
        end)
    end)

    describe("should_skip", function()
        before_each(function()
            reset.all()
        end)

        after_each(function()
            reset.all()
        end)

        it("should return false if there was no last run", function()
            state.last_run.time = nil

            local should_skip = state.last_run.should_skip()

            assert.is_false(should_skip)
        end)

        it("should return true if there was a show action run within the past hour", function()
            state.last_run.update()

            local should_skip = state.last_run.should_skip()

            assert.is_true(should_skip)
        end)

        it("should return false if there was no show action run within the past hour", function()
            local TWO_HOURS_IN_SECONDS = 7200

            -- Simulate 2 hour passing
            state.last_run.time = os.time() - TWO_HOURS_IN_SECONDS

            local should_skip = state.last_run.should_skip()

            assert.is_false(should_skip)
        end)
    end)
end)
