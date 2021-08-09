-- FILE DESCRIPTION: Functionality related to deleting dependency on current line

local Menu = require("nui.menu")

local utils = require("package-info.utils")

----------------------------------------------------------------------------
---------------------------------- HELPERS ---------------------------------
----------------------------------------------------------------------------


local DELETE_ACTIONS = {
    confirm = "Confirm",
    cancel = "Cancel",
}

local display_menu = function(package_name)
    local menu = Menu({
        relative = "cursor",
        border = {
            style = "rounded",
            highlight = "Normal",
            text = {
                top = " Delete [" .. package_name .. "] Package ",
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
            Menu.item(DELETE_ACTIONS.confirm),
            Menu.item(DELETE_ACTIONS.cancel),
        },
        keymap = {
            focus_next = { "j", "<Down>", "<Tab>" },
            focus_prev = { "k", "<Up>", "<S-Tab>" },
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>", "<Space>" },
        },
        on_submit = function(selected_action)
            if selected_action.text == DELETE_ACTIONS.confirm then
                vim.fn.jobstart("yarn remove " .. package_name, {
                    on_stdout = function()
                        vim.api.nvim_echo({ { package_name .. " deleted successfully" } }, {}, {})
                        vim.cmd("e")
                    end,
                })
            end
        end,
    })

    menu:mount()
end

----------------------------------------------------------------------------
------------------------------ RETURN FUNCTION -----------------------------
----------------------------------------------------------------------------

return function()
    local current_line = vim.fn.getline(".")
    local package_name = utils.buffer.get_package_from_line(current_line, true)

    if not package_name then
        vim.api.nvim_echo({ { "No package under current line.", "WarningMsg" } }, {}, {})
    else
        display_menu(package_name)
    end
end
