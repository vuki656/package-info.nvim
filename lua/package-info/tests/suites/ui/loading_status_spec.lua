local expect = MiniTest.expect

local loading = require("package-info.ui.generic.loading-status")

local reset = require("package-info.tests.utils.reset")

local notifications = {}
local original_notify = nil
local original_has_notify_backend = loading.__has_notify_backend
local next_id = 0

--- Replace vim.notify with a stub behaving like a notification backend
-- @return nil
local stub_notify = function()
    notifications = {}
    next_id = 0
    original_notify = vim.notify

    vim.notify = function(message, level, opts)
        opts = opts or {}

        local id = opts.replace or opts.id

        if not id then
            next_id = next_id + 1
            id = next_id
        end

        table.insert(notifications, {
            message = message,
            level = level,
            opts = opts,
            id = id,
            is_fast_event = vim.in_fast_event(),
        })

        return id
    end
end

--- Find the recorded notification with the given message
-- @param message: string
-- @return table|nil
local find_notification = function(message)
    for _, notification in ipairs(notifications) do
        if notification.message == message then
            return notification
        end
    end

    return nil
end

--- Get the notification handle currently held by the instance with the given id
-- @param id: number
-- @return any
local handle_of = function(id)
    for _, instance in ipairs(loading.queue) do
        if instance.id == id then
            return instance.notification
        end
    end

    return nil
end

local T = MiniTest.new_set({
    hooks = {
        pre_case = function()
            reset.all()
            stub_notify()

            loading.__has_notify_backend = true
        end,
        post_case = function()
            loading.queue = {}
            loading.reset_state()

            vim.notify = original_notify
            loading.__has_notify_backend = original_has_notify_backend

            reset.all()
        end,
    },
})

T["stop"] = MiniTest.new_set()

T["stop"]["should replace the notification of its own instance when another instance is running"] = function()
    local first = loading.new("first")
    loading.start(first)

    local second = loading.new("second")
    loading.start(second)

    local first_handle = handle_of(first)
    local second_handle = handle_of(second)

    loading.stop(second, "second done")
    loading.stop(first, "first done")

    expect.equality(find_notification("second done").opts.replace, second_handle)
    expect.equality(find_notification("first done").opts.replace, first_handle)
end

T["stop"]["should not hide notifications it does not own"] = function()
    local id = loading.new("only")
    loading.start(id)

    local handle = handle_of(id)

    loading.stop(id, "done")

    expect.equality(find_notification("done").opts.replace, handle)
    expect.equality(find_notification("done").opts.id, handle)
end

T["update_spinner"] = MiniTest.new_set()

T["update_spinner"]["should update every instance with its own message and handle"] = function()
    local first = loading.new("first")
    loading.start(first)

    local second = loading.new("second")
    loading.start(second)

    local first_handle = handle_of(first)
    local second_handle = handle_of(second)

    notifications = {}

    loading.update_spinner()

    expect.equality(find_notification("first").opts.id, first_handle)
    expect.equality(find_notification("second").opts.id, second_handle)
end

T["spinner timer"] = MiniTest.new_set()

T["spinner timer"]["should not notify from a fast event context"] = function()
    local id = loading.new("spinning")
    loading.start(id)

    notifications = {}

    vim.wait(1000, function()
        return #notifications > 0
    end, 10)

    expect.equality(#notifications > 0, true)

    for _, notification in ipairs(notifications) do
        expect.equality(notification.is_fast_event, false)
    end

    loading.stop(id, "done")
end

return T
