local SPINNERS = {
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
}

local M = {
    queue = {},
    state = {
        current_spinner = "",
        index = 1,
        is_running = false,
        notification = nil,
        timer = nil,
    },
}

local config = require("package-info.config")

-- nvim-notify support
local nvim_notify = pcall(require, "notify")
local title = "package-info.nvim"
local constants = require("package-info.utils.constants")

-- snacks.notifier support
local snacks_notifier = pcall(require, "snacks.notifier")

local snacks = nil
if snacks_notifier then
    local ok, mod = pcall(require, "snacks.notifier")
    if ok then
        snacks = mod
    end
end

--- Spawn a new loading instance
-- @param log: string - message to display in the loading status
-- @return number - id of the created instance
M.new = function(message)
    local instance = {
        id = math.random(),
        message = message,
        is_ready = false,
        notification = nil,
    }

    if (nvim_notify or snacks_notifier) and config.options.notifications then
        instance.notification = vim.notify(message, vim.log.levels.INFO, {
            title = title,
            icon = SPINNERS[1],
            timeout = config.options.timeout,
            hide_from_history = true,
        })
    end

    table.insert(M.queue, instance)

    if not M.state.timer then
        M.state.timer = vim.loop.new_timer()
        M.state.timer:start(60, 60, function()
            M.update_spinner(message)
        end)
    end

    return instance.id
end

--- Start the instance by given id by marking it as ready to run
-- @param id: string - id of the instance to start
-- @return nil
M.start = function(id)
    for _, instance in ipairs(M.queue) do
        if instance.id == id then
            instance.is_ready = true
            M.state.notification = instance.notification
        end
    end
end

--- Stop the instance by given id by removing it from the list
-- @param id: string - id of the instance to stop and remove
-- @param message: string - message to be displayed
-- @param level: number - log level
-- @return nil
M.stop = function(id, message, level)
    if message == nil then
        message = ""
    end
    if level == nil then
        level = vim.log.levels.INFO
    end

    if snacks_notifier and snacks and M.state.notification then
        snacks.hide()
    end

    if (nvim_notify or snacks_notifier) and M.state.notification then
        local level_icon = {
            [vim.log.levels.INFO] = "󰗠 ",
            [vim.log.levels.ERROR] = "󰅙 ",
            [vim.log.levels.WARN] = "  ",
        }

        local new_notif = vim.notify(message, level, {
            title = title,
            icon = level_icon[level],
            replace = M.state.notification,
            timeout = config.options.timeout,
        })
        M.state.notification = new_notif
        M.state.notification = nil
    end

    local filtered_list = {}

    for _, instance in ipairs(M.queue) do
        if instance.id ~= id then
            table.insert(filtered_list, instance)
        end
    end

    M.queue = filtered_list
end

--- Update the spinner instance recursively
-- @return nil
M.update_spinner = function(message)
    M.state.current_spinner = SPINNERS[M.state.index]

    M.state.index = M.state.index % #SPINNERS + 1

    if (nvim_notify or snacks_notifier) and M.state.notification then
        local new_notif = vim.notify(message, vim.log.levels.INFO, {
            title = title,
            hide_from_history = true,
            icon = M.state.current_spinner,
            id = M.state.notification,
            replace = M.state.notification,
        })
        M.state.notification = new_notif
    end

    -- this can be used to post updates (ex. refresh the statusline)
    vim.schedule(function()
        vim.api.nvim_exec_autocmds("User", {
            group = constants.AUTOGROUP,
            pattern = constants.LOAD_EVENT,
        })
    end)
end

--- Get the first ready instance message if there are instances
-- @return string
M.get = function()
    for _, instance in pairs(M.queue) do
        if instance.is_ready then
            if M.state.is_running then
                return instance.message
            end
            M.state.is_running = true
            return instance.message
        end
    end
    M.state.is_running = false
    M.state.current_spinner = ""
    M.state.index = 1
    if M.state.timer then
        M.state.timer:stop()
        M.state.timer:close()
        M.state.timer = nil
        -- ensure this gets called *after* last chedule from update_spinner
        vim.schedule(function()
            vim.api.nvim_exec_autocmds("User", {
                group = constants.AUTOGROUP,
                pattern = constants.LOAD_EVENT,
            })
        end)
    end
    return ""
end

return M
