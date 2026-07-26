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

        assert.is_not_nil(state.namespace.id)
        assert.are.equals(vim.api.nvim_get_namespaces()["package-info"], state.namespace.id)
    end)
end)
