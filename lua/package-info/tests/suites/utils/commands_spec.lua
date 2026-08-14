local expect = MiniTest.expect

local config = require("package-info.config")
local state = require("package-info.state")
local constants = require("package-info.utils.constants")
local commands = require("package-info.utils.commands")

local reset = require("package-info.tests.utils.reset")

local set_package_manager = function(package_manager)
    config.options.package_manager = package_manager
end

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["install returns the development command per package manager"] = function()
    local dev = constants.DEPENDENCY_TYPE.development

    set_package_manager(constants.PACKAGE_MANAGERS.yarn)
    expect.equality(commands.install(dev, "eslint"), "yarn add -D eslint")

    set_package_manager(constants.PACKAGE_MANAGERS.npm)
    expect.equality(commands.install(dev, "eslint"), "npm install --save-dev eslint")

    set_package_manager(constants.PACKAGE_MANAGERS.pnpm)
    expect.equality(commands.install(dev, "eslint"), "pnpm add -D eslint")

    set_package_manager(constants.PACKAGE_MANAGERS.bun)
    expect.equality(commands.install(dev, "eslint"), "bun add -d eslint")
end

T["install returns the production command per package manager"] = function()
    local prod = constants.DEPENDENCY_TYPE.production

    set_package_manager(constants.PACKAGE_MANAGERS.yarn)
    expect.equality(commands.install(prod, "react"), "yarn add react")

    set_package_manager(constants.PACKAGE_MANAGERS.npm)
    expect.equality(commands.install(prod, "react"), "npm install react")

    set_package_manager(constants.PACKAGE_MANAGERS.pnpm)
    expect.equality(commands.install(prod, "react"), "pnpm add react")

    set_package_manager(constants.PACKAGE_MANAGERS.bun)
    expect.equality(commands.install(prod, "react"), "bun add react")
end

T["delete returns the command per package manager"] = function()
    set_package_manager(constants.PACKAGE_MANAGERS.yarn)
    expect.equality(commands.delete("react"), "yarn remove react")

    set_package_manager(constants.PACKAGE_MANAGERS.npm)
    expect.equality(commands.delete("react"), "npm uninstall react")

    set_package_manager(constants.PACKAGE_MANAGERS.pnpm)
    expect.equality(commands.delete("react"), "pnpm remove react")

    set_package_manager(constants.PACKAGE_MANAGERS.bun)
    expect.equality(commands.delete("react"), "bun remove react")
end

T["update returns the command per package manager"] = function()
    set_package_manager(constants.PACKAGE_MANAGERS.yarn)
    expect.equality(commands.update("react"), "yarn up react")

    state.has_old_yarn = true
    expect.equality(commands.update("react"), "yarn upgrade react --latest")

    set_package_manager(constants.PACKAGE_MANAGERS.npm)
    expect.equality(commands.update("react"), "npm install react@latest")

    set_package_manager(constants.PACKAGE_MANAGERS.pnpm)
    expect.equality(commands.update("react"), "pnpm update --latest react")

    set_package_manager(constants.PACKAGE_MANAGERS.bun)
    expect.equality(commands.update("react"), "bun add react@latest")
end

T["change_version returns the command per package manager"] = function()
    set_package_manager(constants.PACKAGE_MANAGERS.yarn)
    expect.equality(commands.change_version("react", "18.0.0"), "yarn up react@18.0.0")

    state.has_old_yarn = true
    expect.equality(commands.change_version("react", "18.0.0"), "yarn upgrade react@18.0.0")

    set_package_manager(constants.PACKAGE_MANAGERS.npm)
    expect.equality(commands.change_version("react", "18.0.0"), "npm install react@18.0.0")

    set_package_manager(constants.PACKAGE_MANAGERS.pnpm)
    expect.equality(commands.change_version("react", "18.0.0"), "pnpm add react@18.0.0")

    set_package_manager(constants.PACKAGE_MANAGERS.bun)
    expect.equality(commands.change_version("react", "18.0.0"), "bun add react@18.0.0")
end

T["version_list silences warnings that would otherwise corrupt the json payload"] = function()
    set_package_manager(constants.PACKAGE_MANAGERS.pnpm)
    expect.equality(commands.version_list("react"), "pnpm --loglevel=error view react versions --json")

    set_package_manager(constants.PACKAGE_MANAGERS.npm)
    expect.equality(commands.version_list("react"), "npm --loglevel=error view react versions --json")

    set_package_manager(constants.PACKAGE_MANAGERS.yarn)
    expect.equality(commands.version_list("react"), "npm --loglevel=error view react versions --json")

    set_package_manager(constants.PACKAGE_MANAGERS.bun)
    expect.equality(commands.version_list("react"), "npm --loglevel=error view react versions --json")
end

T["outdated silences warnings that would otherwise corrupt the json payload"] = function()
    expect.equality(commands.outdated("./temp/pnpm-workspace.yaml"), "pnpm --loglevel=error outdated --json")
    expect.equality(commands.outdated(nil), "npm --loglevel=error outdated --json")
end

return T
