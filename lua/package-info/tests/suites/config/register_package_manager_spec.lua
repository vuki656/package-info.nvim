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
        local package_json = file.create_package_json({ go = true })
        local lock_file_path = vim.fn.fnamemodify(package_json.path, ":h") .. "/package-lock.json"
        local created_file = file.create({ name = lock_file_path })

        config.__register_package_manager()

        file.delete(created_file.path)
        file.delete(package_json.path)

        assert.are.equals(constants.PACKAGE_MANAGERS.npm, config.options.package_manager)
    end)

    it("should detect yarn package manager", function()
        local package_json = file.create_package_json({ go = true })
        local lock_file_path = vim.fn.fnamemodify(package_json.path, ":h") .. "/yarn.lock"
        local created_file = file.create({ name = lock_file_path })

        config.__register_package_manager()

        file.delete(created_file.path)
        file.delete(package_json.path)

        assert.are.equals(constants.PACKAGE_MANAGERS.yarn, config.options.package_manager)
    end)

    it("should detect pnpm package manager", function()
        local package_json = file.create_package_json({ go = true })
        local lock_file_path = vim.fn.fnamemodify(package_json.path, ":h") .. "/pnpm-lock.yaml"
        local created_file = file.create({ name = lock_file_path })

        config.__register_package_manager()

        file.delete(created_file.path)
        file.delete(package_json.path)

        assert.are.equals(constants.PACKAGE_MANAGERS.pnpm, config.options.package_manager)
    end)
end)
