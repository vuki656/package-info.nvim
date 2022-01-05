local commands = require("package-info.commands")
local constants = require("package-info.utils.constants")
local config = require("package-info.config")

describe("Command retrieval for yarn", function()
    config.package_manager = "yarn"

    it("should get the delete command", function()
        local command = commands.get_delete("prettier")

        assert.are.equals("yarn remove prettier", command)
    end)

    it("should get the update command", function()
        local command = commands.get_update("prettier")

        assert.are.equals("yarn up prettier", command)
    end)

    it("should get the development install command", function()
        local command = commands.get_install(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals("yarn add -D prettier", command)
    end)

    it("should get the production install command", function()
        local command = commands.get_install(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals("yarn add prettier", command)
    end)

    it("should get the change version command", function()
        local command = commands.get_change_version("prettier", "3.0.0")

        assert.are.equals("yarn up prettier@3.0.0", command)
    end)
end)

describe("Command retrieval for pnpm", function()
    config.package_manager = "pnpm"

    it("should get the delete command", function()
        local command = commands.get_delete("prettier")

        assert.are.equals("pnpm remove prettier", command)
    end)

    it("should get the update command", function()
        local command = commands.get_update("prettier")

        assert.are.equals("pnpm update prettier", command)
    end)

    it("should get the development install command", function()
        local command = commands.get_install(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals("pnpm add -D prettier", command)
    end)

    it("should get the production install command", function()
        local command = commands.get_install(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals("pnpm add prettier", command)
    end)

    it("should get the change version command", function()
        local command = commands.get_change_version("prettier", "3.0.0")

        assert.are.equals("pnpm add prettier@3.0.0", command)
    end)

    it("should get the list command", function()
        local command = commands.get_version_list("prettier")

        assert.are.equals("pnpm view prettier versions --json", command)
    end)
end)

describe("Command retrieval for npm", function()
    config.package_manager = "npm"

    it("should get the delete command", function()
        local command = commands.get_delete("prettier")

        assert.are.equals("npm uninstall prettier", command)
    end)

    it("should get the update command", function()
        local command = commands.get_update("prettier")

        assert.are.equals("npm install prettier@latest", command)
    end)

    it("should get the development install command", function()
        local command = commands.get_install(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals("npm install --save-dev prettier", command)
    end)

    it("should get the production install command", function()
        local command = commands.get_install(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals("npm install prettier", command)
    end)

    it("should get the change version command", function()
        local command = commands.get_change_version("prettier", "3.0.0")

        assert.are.equals("npm install prettier@3.0.0", command)
    end)
end)

describe("Command retrieval", function()
    it("should get the version list command", function()
        local command = commands.get_version_list("prettier")

        assert.are.equals("npm view prettier versions --json", command)
    end)

    it("should get the outdated packages command", function()
        local command = commands.get_outdated()

        assert.are.equals("npm outdated --json", command)
    end)
end)
