local utils = require("package-info.utils")
local constants = require("package-info.constants")
local config = require("package-info.config")

describe("Command retrieval for yarn", function()
    config.options.package_manager = "yarn"

    it("should get the delete command", function()
        local command = utils.get_command.delete("prettier")

        assert.are.equals("yarn remove prettier", command)
    end)

    it("should get the update command", function()
        local command = utils.get_command.update("prettier")

        assert.are.equals("yarn upgrade --latest prettier", command)
    end)

    it("should get the development install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals("yarn add -D prettier", command)
    end)

    it("should get the production install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals("yarn add prettier", command)
    end)

    it("should get the reinstall command", function()
        local command = utils.get_command.reinstall()

        assert.are.equals("rm -rf node_modules && yarn", command)
    end)

    it("should get the change version command", function()
        local command = utils.get_command.change_version("prettier", "3.0.0")

        assert.are.equals("yarn upgrade prettier@3.0.0", command)
    end)
end)

describe("Command retrieval for pnpm", function()
    config.options.package_manager = "pnpm"

    it("should get the delete command", function()
        local command = utils.get_command.delete("prettier")

        assert.are.equals("pnpm remove prettier", command)
    end)

    it("should get the update command", function()
        local command = utils.get_command.update("prettier")

        assert.are.equals("pnpm update prettier", command)
    end)

    it("should get the development install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals("pnpm add -D prettier", command)
    end)

    it("should get the production install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals("pnpm add prettier", command)
    end)

    it("should get the reinstall command", function()
        local command = utils.get_command.reinstall()

        assert.are.equals("rm -rf node_modules && pnpm install", command)
    end)

    it("should get the change version command", function()
        local command = utils.get_command.change_version("prettier", "3.0.0")

        assert.are.equals("pnpm add prettier@3.0.0", command)
    end)

    it("should get the list command", function()
        local command = utils.get_command.version_list("prettier")

        assert.are.equals("pnpm view prettier versions --json", command)
    end)
end)

describe("Command retrieval for npm", function()
    config.options.package_manager = "npm"

    it("should get the delete command", function()
        local command = utils.get_command.delete("prettier")

        assert.are.equals("npm uninstall prettier", command)
    end)

    it("should get the update command", function()
        local command = utils.get_command.update("prettier")

        assert.are.equals("npm install prettier@latest", command)
    end)

    it("should get the development install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals("npm install --save-dev prettier", command)
    end)

    it("should get the production install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals("npm install prettier", command)
    end)

    it("should get the reinstall command", function()
        local command = utils.get_command.reinstall()

        assert.are.equals("rm -rf node_modules && npm install", command)
    end)

    it("should get the change version command", function()
        local command = utils.get_command.change_version("prettier", "3.0.0")

        assert.are.equals("npm install prettier@3.0.0", command)
    end)
end)

describe("Command retrieval", function()
    it("should get the version list command", function()
        local command = utils.get_command.version_list("prettier")

        assert.are.equals("npm view prettier versions --json", command)
    end)

    it("should get the outdated packages command", function()
        local command = utils.get_command.outdated()

        assert.are.equals("npm outdated --json", command)
    end)
end)

describe("Loading", function()
    it("should start", function()
        local message = "Installing prettier"

        utils.loading.start(message)

        assert.are.equals(true, utils.loading.is_running)
        assert.are.equals(message, utils.loading.log)
        assert.are_not.equals(1, utils.loading.index)
        assert.are_not.equals("", utils.loading.spinner)

        utils.loading.stop()
    end)

    it("should stop", function()
        utils.loading.start("Installing prettier")

        vim.fn.timer_start(80, function()
            utils.loading.stop()

            assert.are.equals(false, utils.loading.is_running)
            assert.are.equals("", utils.loading.log)
            assert.are.equals("", utils.loading.spinner)
            assert.are.equals(1, utils.loading.index)
        end)
    end)

    it("should get the status", function()
        utils.loading.start("Installing prettier")

        local status = utils.loading.fetch()

        utils.loading.stop()

        assert.are_not.equals("", status)
    end)
end)
