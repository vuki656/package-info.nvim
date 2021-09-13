local utils = require("package-info.utils")
local constants = require("package-info.constants")
local config = require("package-info.config")

equals = assert.are.equals
not_equals = assert.are_not.equals

describe("Command retrieval for yarn", function()
    config.options.package_manager = "yarn"

    it("should get the delete command", function()
        local command = utils.get_command.delete("prettier")

        equals(command, "yarn remove prettier")
    end)

    it("should get the update command", function()
        local command = utils.get_command.update("prettier")

        equals(command, "yarn upgrade --latest prettier")
    end)

    it("should get the development install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.development, "prettier")

        equals(command, "yarn add -D prettier")
    end)

    it("should get the production install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.production, "prettier")

        equals(command, "yarn add prettier")
    end)

    it("should get the reinstall command", function()
        local command = utils.get_command.reinstall()

        equals(command, "rm -rf node_modules && yarn")
    end)

    it("should get the change version command", function()
        local command = utils.get_command.change_version("prettier", "3.0.0")

        equals(command, "yarn upgrade prettier@3.0.0")
    end)
end)

describe("Command retrieval for npm", function()
    config.options.package_manager = "npm"

    it("should get the delete command", function()
        local command = utils.get_command.delete("prettier")

        equals(command, "npm uninstall prettier")
    end)

    it("should get the update command", function()
        local command = utils.get_command.update("prettier")

        equals(command, "npm install prettier@latest")
    end)

    it("should get the development install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.development, "prettier")

        equals(command, "npm install --save-dev prettier")
    end)

    it("should get the production install command", function()
        local command = utils.get_command.install(constants.DEPENDENCY_TYPE.production, "prettier")

        equals(command, "npm install prettier")
    end)

    it("should get the reinstall command", function()
        local command = utils.get_command.reinstall()

        equals(command, "rm -rf node_modules && npm install")
    end)

    it("should get the change version command", function()
        local command = utils.get_command.change_version("prettier", "3.0.0")

        equals(command, "npm install prettier@3.0.0")
    end)
end)

describe("Command retrieval", function()
    it("should get the version list command", function()
        local command = utils.get_command.version_list("prettier")

        equals(command, "npm view prettier versions --json")
    end)

    it("should get the outdated packages command", function()
        local command = utils.get_command.outdated()

        equals(command, "npm outdated --json")
    end)
end)

describe("Loading", function()
    it("should start", function()
        utils.loading.start("Installing prettier")

        equals(utils.loading.is_running, true)
    end)

    it("should start", function()
        utils.loading.start("Installing prettier")
        utils.loading.stop()

        assert.are.equals(utils.loading.is_running, false)
        equals(utils.loading.log, "")
        equals(utils.loading.spinner, "")
    end)

    it("should set the message", function()
        local message = "Installing prettier"

        utils.loading.start(message)

        equals(utils.loading.log, message)
    end)

    it("should start the loading animation", function()
        utils.loading.start("Installing prettier")

        not_equals(utils.loading.spinner, "")
    end)

    it("should get the status", function()
        utils.loading.start("Installing prettier")

        local status = utils.loading.fetch()

        assert.are_not.equals(status, "")
    end)
end)
