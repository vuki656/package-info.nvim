local Menu = require("nui.menu")

local safe_call = require("package-info.utils.safe-call")
local logger = require("package-info.utils.logger")

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

--- Spawn a new generic confirm/cancel prompt
-- @param props.title: string - displayed at the top of the prompt
-- @param props.command: string - command executed on confirm select
-- @param props.on_submit: function - executed after successful command execution
-- @param props.on_cancel: function - executed if user selects PROMPT_ACTIONS.cancel
-- @param props.on_error: function - executed if command execution throws an error
M.new = function(props)
    local style = {
        relative = "cursor",
        border = {
            style = "rounded",
            highlight = "Normal",
            text = {
                top = props.title,
                top_align = "center",
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
        on_submit = function(answer)
            if answer.id ~= ACTIONS.CONFIRM.id then
                props.on_cancel()

                return
            end

            props.on_submit()
        end,
        on_close = function()
            props.on_cancel()
        end,
    })
end

--- Opens the prompt
-- @param props.on_success?: function - executed after successful prompt open
-- @param props.on_error?: function - executed if prompt instance not properly spawned
M.open = function(props)
    props = props or {}

    if M.instance == nil then
        logger.error("Failed to open prompt. Not spawned properly")

        safe_call(props.on_error)

        return
    end

    M.instance:mount()

    safe_call(props.on_success)
end

--- Closes the prompt
-- @param props.on_success?: function - executed after successful prompt close
-- @param props.on_error?: function - executed if prompt instance not properly spawned or opened
M.close = function(props)
    props = props or {}

    if M.instance == nil then
        logger.error("Failed to close prompt. Not spawned properly")

        safe_call(props.on_error)

        return
    end

    M.instance:unmount()

    safe_call(props.on_success)
end

return M
