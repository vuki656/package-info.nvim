local constants = require("package-info.utils.constants")
local config = require("package-info.config")

local delete_action = require("package-info.actions.delete")
local update_action = require("package-info.actions.update")
local install_action = require("package-info.actions.install")
local change_version_action = require("package-info.actions.change-version")
local show_action = require("package-info.actions.show")

describe("Command retrieval for yarn", function()
    config.options.package_manager = "yarn"

    it("should get the delete command", function()
        local command = delete_action.__get_command("prettier")

        assert.are.equals("yarn remove prettier", command)
    end)

    it("should get the update command", function()
        local command = update_action.__get_command("prettier")

        assert.are.equals("yarn up prettier", command)
    end)

    it("should get the development install command", function()
        local command = install_action.__get_command(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals("yarn add -D prettier", command)
    end)

    it("should get the production install command", function()
        local command = install_action.__get_command(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals("yarn add prettier", command)
    end)

    it("should get the change version command", function()
        local command = change_version_action.__get_change_version_command("prettier", "3.0.0")

        assert.are.equals("yarn up prettier@3.0.0", command)
    end)
end)

describe("Command retrieval for pnpm", function()
    config.options.package_manager = "pnpm"

    it("should get the delete command", function()
        local command = delete_action.__get_command("prettier")

        assert.are.equals("pnpm remove prettier", command)
    end)

    it("should get the update command", function()
        local command = update_action.__get_command("prettier")

        assert.are.equals("pnpm update prettier", command)
    end)

    it("should get the development install command", function()
        local command = install_action.__get_command(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals("pnpm add -D prettier", command)
    end)

    it("should get the production install command", function()
        local command = install_action.__get_command(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals("pnpm add prettier", command)
    end)

    it("should get the change version command", function()
        local command = change_version_action.__get_change_version_command("prettier", "3.0.0")

        assert.are.equals("pnpm add prettier@3.0.0", command)
    end)

    it("should get the list command", function()
        local command = change_version_action.__get_version_list_command("prettier")

        assert.are.equals("pnpm view prettier versions --json", command)
    end)
end)

describe("Command retrieval for npm", function()
    config.options.package_manager = "npm"

    it("should get the delete command", function()
        local command = delete_action.__get_command("prettier")

        assert.are.equals("npm uninstall prettier", command)
    end)

    it("should get the update command", function()
        local command = update_action.__get_command("prettier")

        assert.are.equals("npm install prettier@latest", command)
    end)

    it("should get the development install command", function()
        local command = install_action.__get_command(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals("npm install --save-dev prettier", command)
    end)

    it("should get the production install command", function()
        local command = install_action.__get_command(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals("npm install prettier", command)
    end)

    it("should get the change version command", function()
        local command = change_version_action.__get_change_version_command("prettier", "3.0.0")

        assert.are.equals("npm install prettier@3.0.0", command)
    end)
end)

describe("Command retrieval", function()
    it("should get the version list command", function()
        local command = change_version_action.__get_version_list_command("prettier")

        assert.are.equals("npm view prettier versions --json", command)
    end)

    it("should get the outdated packages command", function()
        local command = show_action.__get_command()

        assert.are.equals("npm outdated --json", command)
    end)
end)
