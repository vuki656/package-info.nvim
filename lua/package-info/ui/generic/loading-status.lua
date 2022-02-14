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
    },
}

--- Spawn a new loading instance
-- @param log: string - message to display in the loading status
-- @return number - id of the created instance
M.new = function(message)
    local instance = {
        id = math.random(),
        message = message,
        is_ready = false,
    }

    table.insert(M.queue, instance)

    return instance.id
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
-- @return nil
M.stop = function(id)
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
M.update_spinner = function()
    M.state.current_spinner = SPINNERS[M.state.index]

    M.state.index = M.state.index + 1

    if M.state.index == 10 then
        M.state.index = 1
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

        M.update_spinner()
    end

    return active_instance.message
end

return M
