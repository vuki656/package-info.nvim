local spy = require("luassert.spy")

local core = require("package-info.core")
local to_boolean = require("package-info.utils.to-boolean")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Core load_plugin", function()
    before_each(function()
        reset.core()

        vim.opt.swapfile = false
    end)

    it("should return nil if not in package.json", function()
        local is_loaded = to_boolean(core.load_plugin())

        assert.is_false(is_loaded)
    end)

    it("should load the plugin if in package.json", function()
        file.create_package_json({ go = true })

        spy.on(core, "parse_buffer")

        core.load_plugin()

        file.delete_package_json()

        assert.spy(core.parse_buffer).was_called()
    end)
end)
