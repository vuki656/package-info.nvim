local core = require("package-info.core")

local reset = require("package-info.tests.utils.reset")

describe("Core decode_json_string", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should return nil if json is invalid", function()
        local json_value = core.__decode_json_string('{ l "name": "test" }')

        assert.is_nil(json_value)
    end)

    it("should decoded json if json is valid", function()
        local json_value = core.__decode_json_string('{ "name": "test" }')

        assert.are.same({ name = "test" }, json_value)
    end)
end)
