local Menu = require("nui.menu")

local safe_call = require("package-info.utils.safe-call")
local logger = require("package-info.logger")

local M = {}

M.new = function(props)
    local style = {
        relative = "cursor",
        position = {
            row = 0,
            col = 0,
        },
        size = {
            width = 30,
            height = 20,
        },
        highlight = "Normal:Normal",
        focusable = true,
        border = {
            style = "rounded",
            highlight = "Normal",
            text = {
                top = " Select Version ",
                top_align = "left",
            },
        },
    }

    M.instance = Menu(style, {
        lines = props.version_list,
        keymap = {
            focus_next = { "j", "<Down>", "<Tab>" },
            focus_prev = { "k", "<Up>", "<S-Tab>" },
            close = { "<Esc>", "<C-c>", "q" },
            submit = { "<CR>", "<Space>" },
        },
        on_submit = function(selected_version)
            props.on_submit(selected_version.text)
        end,
        on_close = function()
            safe_call(props.on_cancel)
        end,
    })
end

--- Opens the prompt
-- @param props.on_success?: function - executed after successful prompt open
-- @param props.on_error?: function - executed if prompt instance not properly spawned
M.open = function(props)
    props = props or {}

    if M.instance == nil then
        logger.error("Failed to open select dependency type prompt. Not spawned properly")

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
        logger.error("Failed to close select dependency type prompt. Not spawned properly")

        safe_call(props.on_error)

        return
    end

    M.instance:unmount()

    safe_call(props.on_success)
end

return M
