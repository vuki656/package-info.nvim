local core = require("package-info.core")

describe("Core decode_json_string", function()
    it("should return nil if json is invalid", function()
        local json_value = core.__decode_json_string('{ l "name": "test" }')

        assert.is_nil(json_value)
    end)

    it("should decoded json if json is valid", function()
        local json_value = core.__decode_json_string('{ "name": "test" }')

        assert.are.same({ name = "test" }, json_value)
    end)
end)
