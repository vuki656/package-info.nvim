local utils = require("package-info.utils")
local constants = require("package-info.constants")
local config = require("package-info.config")

describe("Command retrieval for yarn", function()
    config.options.package_manager = "yarn"

    it("should get the delete command", function()
        local command = utils.get_command.delete("prettier")

        assert.are.equals(command, "yarn remove prettier")
    end)

    it("should get the update command", function()
        local command = utils.get_command.update("prettier")

        assert.are.equals(command, "yarn upgrade --latest prettier")
    end)

    it("should get the development install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals(command, "yarn add -D prettier")
    end)

    it("should get the production install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals(command, "yarn add prettier")
    end)

    it("should get the reinstall command", function()
        local command = utils.get_command.reinstall()

        assert.are.equals(command, "rm -rf node_modules && yarn")
    end)

    it("should get the change version command", function()
        local command = utils.get_command.change_version("prettier", "3.0.0")

        assert.are.equals(command, "yarn upgrade prettier@3.0.0")
    end)
end)

describe("Command retrieval for npm", function()
    config.options.package_manager = "npm"

    it("should get the delete command", function()
        local command = utils.get_command.delete("prettier")

        assert.are.equals(command, "npm uninstall prettier")
    end)

    it("should get the update command", function()
        local command = utils.get_command.update("prettier")

        assert.are.equals(command, "npm install prettier@latest")
    end)

    it("should get the development install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.development, "prettier")

        assert.are.equals(command, "npm install --save-dev prettier")
    end)

    it("should get the production install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.production, "prettier")

        assert.are.equals(command, "npm install prettier")
    end)

    it("should get the reinstall command", function()
        local command = utils.get_command.reinstall()

        assert.are.equals(command, "rm -rf node_modules && npm install")
    end)

    it("should get the change version command", function()
        local command = utils.get_command.change_version("prettier", "3.0.0")

        assert.are.equals(command, "npm install prettier@3.0.0")
    end)
end)

describe("Command retrieval", function()
    it("should get the version list command", function()
        local command = utils.get_command.version_list("prettier")

        assert.are.equals(command, "npm view prettier versions --json")
    end)

    it("should get the outdated packages command", function()
        local command = utils.get_command.outdated()

        assert.are.equals(command, "npm outdated --json")
    end)
end)

describe("Loading", function()
    it("should start", function()
        utils.loading.start("Installing prettier")

        assert.are.equals(utils.loading.is_running, true)
    end)

    it("should start", function()
        utils.loading.start("Installing prettier")
        utils.loading.stop()

        assert.are.equals(utils.loading.is_running, false)
        assert.are.equals(utils.loading.log, "")
        assert.are.equals(utils.loading.spinner, "")
    end)

    it("should set the message", function()
        local message = "Installing prettier"

        utils.loading.start(message)

        assert.are.equals(utils.loading.log, message)
    end)

    it("should start the loading animation", function()
        utils.loading.start("Installing prettier")

        assert.are_not.equals(utils.loading.spinner, "")
    end)

    it("should get the status", function()
        utils.loading.start("Installing prettier")

        local status = utils.loading.fetch()

        assert.are_not.equals(status, "")
    end)
end)
