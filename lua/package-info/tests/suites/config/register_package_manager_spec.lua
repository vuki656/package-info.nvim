local constants = require("package-info.utils.constants")
local config = require("package-info.config")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Config register_package_manager", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should detect npm package manager", function()
        local created_file = file.create({ name = "package-lock.json" })

        config.__register_package_manager()

        file.delete(created_file.path)

        assert.are.equals(constants.PACKAGE_MANAGERS.npm, config.options.package_manager)
    end)

    it("should detect yarn package manager", function()
        local created_file = file.create({ name = "yarn.lock" })

        config.__register_package_manager()

        file.delete(created_file.path)

        assert.are.equals(constants.PACKAGE_MANAGERS.yarn, config.options.package_manager)
    end)

    it("should detect pnpm package manager", function()
        local created_file = file.create({ name = "pnpm-lock.yaml" })

        config.__register_package_manager()

        file.delete(created_file.path)

        assert.are.equals(constants.PACKAGE_MANAGERS.pnpm, config.options.package_manager)
    end)
end)
