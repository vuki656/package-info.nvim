local config = require("package-info.config")
local state = require("package-info.state")
local constants = require("package-info.utils.constants")

local M = {}

local YARN_OLD = "yarn_old"

--- Returns the executable with warnings kept out of stdout, since they would
--- land ahead of the json payload and make it impossible to decode
-- @param executable: string - one of constants.PACKAGE_MANAGERS
-- @return string
local get_silenced_executable = function(executable)
    return executable .. " --loglevel=error"
end

local VERSION_LIST_TEMPLATE = get_silenced_executable("npm") .. " view %s versions --json"

local TEMPLATES = {
    install = {
        [constants.DEPENDENCY_TYPE.development] = {
            [constants.PACKAGE_MANAGERS.yarn] = "yarn add -D %s",
            [constants.PACKAGE_MANAGERS.npm] = "npm install --save-dev %s",
            [constants.PACKAGE_MANAGERS.pnpm] = "pnpm add -D %s",
            [constants.PACKAGE_MANAGERS.bun] = "bun add -d %s",
        },
        [constants.DEPENDENCY_TYPE.production] = {
            [constants.PACKAGE_MANAGERS.yarn] = "yarn add %s",
            [constants.PACKAGE_MANAGERS.npm] = "npm install %s",
            [constants.PACKAGE_MANAGERS.pnpm] = "pnpm add %s",
            [constants.PACKAGE_MANAGERS.bun] = "bun add %s",
        },
    },
    delete = {
        [constants.PACKAGE_MANAGERS.yarn] = "yarn remove %s",
        [constants.PACKAGE_MANAGERS.npm] = "npm uninstall %s",
        [constants.PACKAGE_MANAGERS.pnpm] = "pnpm remove %s",
        [constants.PACKAGE_MANAGERS.bun] = "bun remove %s",
    },
    update = {
        [constants.PACKAGE_MANAGERS.yarn] = "yarn up %s",
        [YARN_OLD] = "yarn upgrade %s --latest",
        [constants.PACKAGE_MANAGERS.npm] = "npm install %s@latest",
        [constants.PACKAGE_MANAGERS.pnpm] = "pnpm update --latest %s",
        [constants.PACKAGE_MANAGERS.bun] = "bun add %s@latest",
    },
    change_version = {
        [constants.PACKAGE_MANAGERS.yarn] = "yarn up %s@%s",
        [YARN_OLD] = "yarn upgrade %s@%s",
        [constants.PACKAGE_MANAGERS.npm] = "npm install %s@%s",
        [constants.PACKAGE_MANAGERS.pnpm] = "pnpm add %s@%s",
        [constants.PACKAGE_MANAGERS.bun] = "bun add %s@%s",
    },
    version_list = {
        [constants.PACKAGE_MANAGERS.yarn] = VERSION_LIST_TEMPLATE,
        [constants.PACKAGE_MANAGERS.npm] = VERSION_LIST_TEMPLATE,
        [constants.PACKAGE_MANAGERS.pnpm] = get_silenced_executable("pnpm") .. " view %s versions --json",
        [constants.PACKAGE_MANAGERS.bun] = VERSION_LIST_TEMPLATE,
    },
}

--- Returns the template key for the active package manager, distinguishing yarn v1
-- @return string
local get_manager_key = function()
    if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn and state.has_old_yarn then
        return YARN_OLD
    end

    return config.options.package_manager
end

--- Formats the template matching the active package manager
-- @param templates: table<string, string> - templates keyed by package manager
-- @return string|nil
local get_command = function(templates, ...)
    local template = templates[get_manager_key()] or templates[config.options.package_manager]

    return template and string.format(template, ...)
end

--- Returns the install command based on package manager
-- @param dependency_type: constants.DEPENDENCY_TYPE - dependency type for which to get the command
-- @param dependency_name: string - dependency for which to get the command
-- @return string|nil
M.install = function(dependency_type, dependency_name)
    local templates = TEMPLATES.install[dependency_type]

    return templates and get_command(templates, dependency_name)
end

--- Returns the delete command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @return string|nil
M.delete = function(dependency_name)
    return get_command(TEMPLATES.delete, dependency_name)
end

--- Returns the update command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @return string|nil
M.update = function(dependency_name)
    return get_command(TEMPLATES.update, dependency_name)
end

--- Returns the change version command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @param version: string - used to denote the version to be installed
-- @return string|nil
M.change_version = function(dependency_name, version)
    return get_command(TEMPLATES.change_version, dependency_name, version)
end

--- Returns available package versions command based on package manager
-- @param dependency_name: string - dependency for which to get the command
-- @return string|nil
M.version_list = function(dependency_name)
    return get_command(TEMPLATES.version_list, dependency_name)
end

--- Returns the command that lists the outdated dependencies
-- @param workspace_path: string|nil - path to the pnpm workspace file, if there is one
-- @return string
M.outdated = function(workspace_path)
    if workspace_path then
        return get_silenced_executable("pnpm") .. " outdated --json"
    end

    return get_silenced_executable("npm") .. " outdated --json"
end

return M
