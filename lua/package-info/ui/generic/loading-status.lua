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
    },
}

-- nvim-notify support
local nvim_notify = pcall(require, "notify")
local title = "package-info.nvim"

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

    if nvim_notify then
        instance.notification = vim.notify(message, vim.log.levels.INFO, {
            title = title,
            icon = SPINNERS[1],
            timeout = false,
            hide_from_history = true,
        })
    end

    table.insert(M.queue, instance)

    M.update_spinner(message)

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
    if nvim_notify and M.state.notification then
        local level_icon = {
            [vim.log.levels.INFO] = "󰗠 ",
            [vim.log.levels.ERROR] = "󰅙 ",
            [vim.log.levels.WARN] = "  ",
        }

        local new_notif = vim.notify(message, level, {
            title = title,
            icon = level_icon[level],
            replace = M.state.notification,
            timeout = 3000,
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

    M.state.index = (M.state.index + 1) % #SPINNERS

    if nvim_notify and M.state.notification then
        local new_notif = vim.notify(message, vim.log.levels.INFO, {
            title = title,
            hide_from_history = true,
            icon = M.state.current_spinner,
            replace = M.state.notification,
        })
        M.state.notification = new_notif
    end

    vim.fn.timer_start(60, function()
        M.update_spinner()
    end)
end

--- Get the first ready instance message if there are instances
-- @return string
M.get = function()
    local active_instance = nil

    for _, instance in pairs(M.queue) do
        if not active_instance and instance.is_ready then
            active_instance = instance
        end
    end

    if not active_instance then
        -- FIXME: this is killing all timers, so if a user has any timers, it will interrupt them
        -- like lsp status
        -- vim.fn.timer_stopall()

        M.state.is_running = false
        M.state.current_spinner = ""
        M.state.index = 1

        return ""
    end

    if active_instance and not M.state.is_running then
        M.state.is_running = true

        M.update_spinner(active_instance.message)
    end

    return active_instance.message
end

return M
