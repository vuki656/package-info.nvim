local Menu = require("nui.menu")

local safe_call = require("package-info.utils.safe-call")
local logger = require("package-info.utils.logger")

local M = {}

--- Spawn a version select prompt
-- @param props.on_submit: function - executed after selection
-- @param props.on_cancel?: function - executed if user selects ACTIONS.cancel
-- @return nil
M.new = function(props)
    -- Set height to max 20 and min to (version_list.length === lines)
    local height = math.min(vim.tbl_count(props.version_list), 20)
    local width = 20

    -- Set width to min 20 and max to longest menu item text length
    for _, version in pairs(props.version_list) do
        if width < string.len(version.text) then
            width = string.len(version.text)
        end
    end

    local style = {
        relative = "cursor",
        position = {
            row = 0,
            col = 0,
        },
        size = {
            width = width,
            height = height,
        },
        focusable = true,
        border = {
            style = "rounded",
            text = {
                top = " Select Version ",
                top_align = "center",
            },
        },
        win_options = {
            winhighlight = "Normal:Normal,FloatBorder:Normal",
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
-- @return nil
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
-- @return nil
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
