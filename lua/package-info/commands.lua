local constants = require("package-info.utils.constants")
local config = require("package-info.config")

M = {}

--- Returns the delete command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @return string
M.get_delete = function(dependency_name)
    if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
        return "yarn remove " .. dependency_name
    end

    if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
        return "npm uninstall " .. dependency_name
    end

    if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
        return "pnpm remove " .. dependency_name
    end
end

--- Returns the change version command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @param version: string - used to denote the version to be installed
-- @return string
M.get_change_version = function(dependency_name, version)
    if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
        return "yarn up " .. dependency_name .. "@" .. version
    end

    if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
        return "npm install " .. dependency_name .. "@" .. version
    end

    if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
        return "pnpm add " .. dependency_name .. "@" .. version
    end
end

--- Returns available package versions command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @return string
M.get_version_list = function(dependency_name)
    if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
        return "pnpm view " .. dependency_name .. " versions --json"
    end

    if
        config.options.package_manager == constants.PACKAGE_MANAGERS.npm
        or config.options.package_manager == constants.PACKAGE_MANAGERS.yarn
    then
        return "npm view " .. dependency_name .. " versions --json"
    end
end

--- Returns the install command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @param type: constants.PACKAGE_MANAGERS - package manager for which to get the command
-- @return string
M.get_install = function(type, dependency_name)
    if type == constants.DEPENDENCY_TYPE.development then
        if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn add -D " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm install --save-dev " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm add -D " .. dependency_name
        end
    end

    if type == constants.DEPENDENCY_TYPE.production then
        if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn add " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm install " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm add " .. dependency_name
        end
    end
end

--- Returns command to get outdated dependencies
-- @return string
M.get_outdated = function()
    return "npm outdated --json"
end

--- Returns the update command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @return string
M.get_update = function(dependency_name)
    if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
        return "yarn up " .. dependency_name
    end

    if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
        return "npm install " .. dependency_name .. "@latest"
    end

    if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
        return "pnpm update " .. dependency_name
    end
end

return M
