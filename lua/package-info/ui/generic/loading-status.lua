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

-- Whether a notification backend capable of replacing notifications is available
M.__has_notify_backend = nvim_notify or snacks_notifier

--- Check if notifications should be sent
-- @return boolean
M.__is_notifying = function()
    return M.__has_notify_backend and config.options.notifications
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

    if M.__is_notifying() then
        instance.notification = vim.notify(message, vim.log.levels.INFO, {
            title = title,
            icon = SPINNERS[1],
            timeout = config.options.timeout,
            hide_from_history = true,
        })
    end

    table.insert(M.queue, instance)

    if not M.state.timer then
        -- The timer ticks in a fast event context, where `vim.notify` is not allowed.
        -- Notification backends open and close windows from it, which strands a floating
        -- window nothing can close afterwards, so hop onto the main loop first.
        local tick = vim.schedule_wrap(function()
            if not M.state.timer then
                return
            end

            M.update_spinner()
        end)

        M.state.timer = vim.loop.new_timer()
        M.state.timer:start(60, 60, tick)
    end

    return instance.id
end

--- Get the instance with the given id
-- @param id: number - id of the instance
-- @return table|nil
M.__get = function(id)
    for _, instance in ipairs(M.queue) do
        if instance.id == id then
            return instance
        end
    end

    return nil
end

--- Start the instance by given id by marking it as ready to run
-- @param id: string - id of the instance to start
-- @return nil
M.start = function(id)
    for _, instance in ipairs(M.queue) do
        if instance.id == id then
            instance.is_ready = true
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

    local instance = M.__get(id)

    if instance and instance.notification and M.__is_notifying() then
        local level_icon = {
            [vim.log.levels.INFO] = "󰗠 ",
            [vim.log.levels.ERROR] = "󰅙 ",
            [vim.log.levels.WARN] = "  ",
        }

        vim.notify(message, level, {
            title = title,
            icon = level_icon[level],
            -- `replace` is read by nvim-notify, `id` by snacks.notifier
            replace = instance.notification,
            id = instance.notification,
            timeout = config.options.timeout,
        })

        instance.notification = nil
    end

    local filtered_list = {}

    for _, queued in ipairs(M.queue) do
        if queued.id ~= id then
            table.insert(filtered_list, queued)
        end
    end
    if #filtered_list == 0 then
        M.reset_state()
    end
    M.queue = filtered_list
end

--- Update the spinner instance recursively
-- @return nil
M.update_spinner = function()
    M.state.current_spinner = SPINNERS[M.state.index]

    M.state.index = M.state.index % #SPINNERS + 1

    if M.__is_notifying() then
        for _, instance in ipairs(M.queue) do
            if instance.notification then
                instance.notification = vim.notify(instance.message, vim.log.levels.INFO, {
                    title = title,
                    hide_from_history = true,
                    icon = M.state.current_spinner,
                    id = instance.notification,
                    replace = instance.notification,
                })
            end
        end
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
            return instance.message
        end
    end
    return ""
end

M.reset_state = function()
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
end
return M
