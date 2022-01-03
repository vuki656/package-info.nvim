local json_parser

if vim.json then
    json_parser = vim.json
else
    json_parser = require("package-info.libs.json_parser")
end

local constants = require("package-info.constants")
local logger = require("package-info.logger")
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

--- Runs an async job
-- @param options.command - string command to run
-- @param options.json - boolean if output should be parsed as json
-- @param options.on_success - function to invoke with the results
-- @param options.on_error - function to invoke if the command fails
-- @param options.ignore_error - ignore non-zero exit codes
M.job = function(options)
    local value = ""

    vim.fn.jobstart(options.command, {
        on_exit = function(_, exit_code)
            if exit_code ~= 0 and not options.ignore_error then
                logger.error("Error running " .. options.command .. ". Try running manually.")
                if options.on_error ~= nil then
                    options.on_error()
                end

                return
            end

            if options.json then
                local ok, json_value = pcall(json_parser.decode, value)

                if ok then
                    options.on_success(json_value)
                else
                    logger.error("Error running " .. options.command .. ". Try running manually.")
                    if options.on_error ~= nil then
                        options.on_error()
                    end
                end
            else
                options.on_success(value)
            end
        end,
        on_stdout = function(_, stdout)
            value = value .. table.concat(stdout)
        end,
    })
end

--- Gets appropriate run command based on action and package manager
M.get_command = {
    --- Returns the delete command based on package manager
    -- @param package-name - string
    delete = function(package_name)
        if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn remove " .. package_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm uninstall " .. package_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm remove " .. package_name
        end
    end,

    --- Returns the update command based on package manager
    -- @param package-name - string
    update = function(package_name)
        if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn up " .. package_name
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm install " .. package_name .. "@latest"
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm update " .. package_name
        end
    end,

    --- Returns the install command based on package manager
    -- @param type - one of constants.PACKAGE_MANAGERS
    -- @param package_name - string used to denote the package
    install = function(type, package_name)
        if type == constants.DEPENDENCY_TYPE.development then
            if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
                return "yarn add -D " .. package_name
            end

            if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
                return "npm install --save-dev " .. package_name
            end

            if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
                return "pnpm add -D " .. package_name
            end
        end

        if type == constants.DEPENDENCY_TYPE.production then
            if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
                return "yarn add " .. package_name
            end

            if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
                return "npm install " .. package_name
            end

            if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
                return "pnpm add " .. package_name
            end
        end
    end,

    --- Returns the change version command based on package manager
    -- @param package_name - string used to denote the package installed
    -- @param version - string used to denote the version installed
    change_version = function(package_name, version)
        if config.options.package_manager == constants.PACKAGE_MANAGERS.yarn then
            return "yarn up " .. package_name .. "@" .. version
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.npm then
            return "npm install " .. package_name .. "@" .. version
        end

        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm add " .. package_name .. "@" .. version
        end
    end,

    --- Returns available package versions
    -- @param package_name - string used to denote the package
    version_list = function(package_name)
        if config.options.package_manager == constants.PACKAGE_MANAGERS.pnpm then
            return "pnpm view " .. package_name .. " versions --json"
        end

        return "npm view " .. package_name .. " versions --json"
    end,

    --- Returns command to get outdated dependencies
    outdated = function()
        return "npm outdated --json"
    end,
}

return M
