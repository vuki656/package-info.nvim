local Menu = require("nui.menu")

local buffer_parser = require("package-info.buffer_parser")

local DELETE_ACTIONS = {
    confirm = "Confirm",
    cancel = "Cancel",
}

local check_package = function(package_name)
    local json_value = buffer_parser.parse_buffer()

    local dev_dependencies = json_value["devDependencies"] or {}
    local prod_dependencies = json_value["dependencies"] or {}
    local peer_dependencies = json_value["peerDependencies"] or {}

    if dev_dependencies[package_name] or prod_dependencies[package_name] or peer_dependencies[package_name] then
        return true
    end

    return false
end

local M = {}

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

M.on_delete = function()
    local current_line = vim.fn.getline(".")
    local package_name = string.match(current_line, [["(.-)"]]) or ""

    local is_package = check_package(package_name)

    if package_name == "" then
        vim.api.nvim_echo({ { "No package under current line.", "WarningMsg" } }, {}, {})
    elseif is_package == false then
        vim.api.nvim_echo({ { "No package found on current line.", "WarningMsg" } }, {}, {})
    else
        display_menu(package_name)
    end
end

return M
