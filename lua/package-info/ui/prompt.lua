local Menu = require("nui.menu")

local PROMPT_ACTIONS = {
    confirm = "Confirm",
    cancel = "Cancel",
}

local M = {}

M.display = function(props)
    local menu = Menu({
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
    }, {
        lines = {
            Menu.item(PROMPT_ACTIONS.confirm),
            Menu.item(PROMPT_ACTIONS.cancel),
        },

        on_submit = function(selected_action)
            if selected_action.text == PROMPT_ACTIONS.confirm then
                props.on_submit()
            end
        end,
    })

    menu:mount()
end

return M
