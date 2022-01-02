local Menu = require("nui.menu")

local job = require("package-info.utils.job")
local logger = require("package-info.logger")

local ACTIONS = {
    CONFIRM = {
        id = 1,
        text = "Confirm",
    },
    CANCEL = {
        id = 2,
        text = "Cancel",
    },
}

local M = {}

-- TODO: calculate prompt width based on title (package name) length
--- Generic confirm/cancel prompt
-- @param props.title: string - displayed at the top of the prompt
-- @param props.command: string - command executed on confirm select
-- @param props.on_submit: function - executed after successful command execution
-- @param props.on_cancel: function - executed if user selects PROMPT_ACTIONS.cancel
-- @param props.on_error: function - executed if command execution throws an error
M.New = function(props)
    local style = {
        relative = "cursor",
        border = {
            style = "rounded",
            highlight = "Normal",
            text = {
                top = props.title,
                top_align = "left",
            },
        },
        position = {
            row = 0,
            col = 0,
        },
        size = {
            width = 50,
            height = 2,
        },
        highlight = "Normal:Normal",
        focusable = true,
    }

    M.instance = Menu(style, {
        lines = {
            Menu.item(ACTIONS.CONFIRM),
            Menu.item(ACTIONS.CANCEL),
        },
        keymap = {
            focus_next = { "j", "<Down>", "<Tab>" },
            focus_prev = { "k", "<Up>", "<S-Tab>" },
            close = { "<Esc>", "<C-c>", "q" },
            submit = { "<CR>", "<Space>" },
        },
        on_submit = function(selected_action)
            if selected_action.id == ACTIONS.CONFIRM.id then
                job({
                    json = false,
                    command = props.command,
                    on_success = function()
                        props.on_submit()
                    end,
                    on_error = function()
                        props.on_error()
                    end,
                })
            else
                props.on_cancel()
            end
        end,
        on_close = function()
            props.on_cancel()
        end,
    })
end

--- Opens the prompt
-- @param props.on_error: function - executed if prompt instance not properly spawned
-- @param props.on_success: function - executed after successful prompt open
M.Open = function(props)
    if M.instance == nil then
        logger.error("Failed to open prompt. Not spawned properly")

        props.on_error()

        return
    end

    M.instance:mount()

    if props.on_success ~= nil then
        props.on_success()
    end
end

--- Closes the prompt
-- @param props.on_error: function - executed if prompt instance not properly spawned or opened
-- @param props.on_success: function - executed after successful prompt close
M.Close = function(props)
    if M.instance == nil then
        logger.error("Failed to close prompt. Not spawned properly")

        props.on_error()

        return
    end

    M.instance:unmount()

    if props.on_success ~= nil then
        props.on_success()
    end
end

return M
