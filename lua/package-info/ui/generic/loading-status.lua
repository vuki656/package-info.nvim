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
    instances = {},
}

-- FIXME: each new instance spins faster and faster
--- Spawn a new loading instance
-- @param log: string - message to display in the loading status
M.new = function(log)
    local state = {
        index = 1,
        id = math.random(),
        log = log,
        current_spinner = "",
        is_ready = false,
        is_running = false,
    }

    function get_message()
        return state.current_spinner .. " " .. state.log
    end

    function update()
        state.current_spinner = SPINNERS[state.index]

        state.index = state.index + 1

        if state.index == 10 then
            state.index = 1
        end

        vim.fn.timer_start(80, function()
            update()
        end)
    end

    function start()
        if not state.is_running then
            update()

            state.is_running = true
        end
    end

    local instance = vim.tbl_deep_extend("force", state, {
        get_message = get_message,
        update = update,
        start = start,
    })

    table.insert(M.instances, instance)

    return instance.id
end

--- Start the instance by given id
-- @param id: string - id of the instance to start
M.start = function(id)
    for _, instance in pairs(M.instances) do
        if instance.id == id then
            instance.is_ready = true

            return
        end
    end
end

--- Stop the instance by given id by removing it from the list
-- @param id: string - id of the instance to stop
M.stop = function(id)
    local instances = {}

    for _, instance in pairs(M.instances) do
        if instance.id ~= id then
            table.insert(instances, instance)
        end
    end

    M.instances = instances
end

--- Get the first instance message if there are instances
M.get = function()
    if vim.tbl_isempty(M.instances) then
        return ""
    else
        local instance = M.instances[1]

        if instance.is_ready and not instance.is_running then
            instance.start()
        end

        return instance.get_message()
    end
end

return M