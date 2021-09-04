local Menu = require("nui.menu")

local ACTIONS = {
    confirm = "Confirm",
    cancel = "Cancel",
}

local M = {}

M.display_menu = function(options)
    local menu = Menu({
        relative = "cursor",
        border = {
            style = "rounded",
            highlight = "Normal",
            text = {
                top = options.title,
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
    }, {
        lines = {
            Menu.item(ACTIONS.confirm),
            Menu.item(ACTIONS.cancel),
        },
        keymap = {
            focus_next = { "j", "<Down>", "<Tab>" },
            focus_prev = { "k", "<Up>", "<S-Tab>" },
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>", "<Space>" },
        },
        on_submit = function(selected_action)
            if selected_action.text == ACTIONS.confirm then
                vim.fn.jobstart(options.command, {
                    on_stdout = function(_, stdout)
                        if table.concat(stdout) == "" then
                            options.callback()
                        end
                    end,
                })
            end
        end,
    })

    menu:mount()
end

return M
