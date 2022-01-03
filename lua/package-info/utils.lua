-- TODO: split into multiple files

local constants = require("package-info.constants")
local config = require("package-info.config")

M = {}

-- TODO: assign id to loading instance
--- Manages loading animation state
M.loading = {
    animation = {
        "⠋",
        "⠙",
        "⠹",
        "⠸",
        "⠼",
        "⠴",
        "⠦",
        "⠧",
        "⠇",
        "⠏",
    },
    index = 1,
    log = "",
    spinner = "",
    is_running = false,
    fetch = function()
        return M.loading.spinner .. " " .. M.loading.log
    end,
    start = function(message)
        M.loading.log = message
        M.loading.is_running = true
        M.loading.update()
    end,
    stop = function()
        M.loading.is_running = false
        M.loading.log = ""
        M.loading.spinner = ""
        M.loading.index = 1
    end,
    update = function()
        if M.loading.is_running then
            M.loading.spinner = M.loading.animation[M.loading.index]

            M.loading.index = M.loading.index + 1

            if M.loading.index == 10 then
                M.loading.index = 1
            end

            vim.fn.timer_start(80, function()
                M.loading.update()
            end)
        end
    end,
}

--- Gets appropriate run command based on action and package manager
M.get_command = {
    --- Returns the delete command based on package manager
    -- @param package-name - string
    delete = function(dependency_name)
        if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn remove " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm uninstall " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm remove " .. dependency_name
        end
    end,

    --- Returns the update command based on package manager
    -- @param package-name - string
    update = function(dependency_name)
        if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn up " .. dependency_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm install " .. dependency_name .. "@latest"
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm update " .. dependency_name
        end
    end,

    --- Returns the install command based on package manager
    -- @param type - one of constants.PACKAGE_MANAGERS
    -- @param dependency_name - string used to denote the package
    install = function(type, dependency_name)
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
    end,

    --- Returns the change version command based on package manager
    -- @param dependency_name - string used to denote the package installed
    -- @param version - string used to denote the version installed
    change_version = function(dependency_name, version)
        if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn up " .. dependency_name .. "@" .. version
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm install " .. dependency_name .. "@" .. version
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm add " .. dependency_name .. "@" .. version
        end
    end,

    --- Returns available package versions
    -- @param dependency_name - string used to denote the package
    version_list = function(dependency_name)
        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm view " .. dependency_name .. " versions --json"
        end

        return "npm view " .. dependency_name .. " versions --json"
    end,

    --- Returns command to get outdated dependencies
    outdated = function()
        return "npm outdated --json"
    end,
}

return M
