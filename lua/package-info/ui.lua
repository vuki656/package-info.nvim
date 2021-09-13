local Menu = require("nui.menu")
local Input = require("nui.input")

local constants = require("package-info.constants")
local utils = require("package-info.utils")

local PROMPT_ACTIONS = {
    confirm = "Confirm",
    cancel = "Cancel",
}

local INSTALL_ACTIONS = {
    prod = {
        text = "Production",
        id = constants.DEPENDENCY_TYPE.production,
    },
    dev = {
        text = "Development",
        id = constants.DEPENDENCY_TYPE.development,
    },
    cancel = {
        text = "Cancel",
        id = "cancel",
    },
}

local M = {}

--- Generic confirm/cancel prompt
-- @param options.title - string
-- @param options.command - string used as command executed on confirm
-- @param options.callback - function used after command executed
M.display_prompt = function(options)
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
            Menu.item(PROMPT_ACTIONS.confirm),
            Menu.item(PROMPT_ACTIONS.cancel),
        },
        keymap = {
            focus_next = { "j", "<Down>", "<Tab>" },
            focus_prev = { "k", "<Up>", "<S-Tab>" },
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>", "<Space>" },
        },
        on_submit = function(selected_action)
            if selected_action.text == PROMPT_ACTIONS.confirm then
                utils.job({
                    json = false,
                    command = options.command,
                    on_success = function()
                        options.on_submit()
                    end,
                    on_error = function()
                        options.on_cancel()
                    end,
                })
            else
                options.on_cancel()
            end
        end,
    })

    menu:mount()
end

--- Menu to choose the type of dependency to be installed
M.display_install_menu = function(callback)
    local menu = Menu({
        relative = "cursor",
        position = {
            row = 0,
            col = 0,
        },
        size = {
            width = 50,
            height = 3,
        },
        highlight = "Normal:Normal",
        focusable = true,
        border = {
            style = "rounded",
            highlight = "Normal",
            text = {
                top = " Select Dependency Type ",
                top_align = "left",
            },
        },
    }, {
        lines = {
            Menu.item(INSTALL_ACTIONS.prod),
            Menu.item(INSTALL_ACTIONS.dev),
            Menu.item(INSTALL_ACTIONS.cancel),
        },
        keymap = {
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>", "<Space>" },
        },
        on_submit = function(answer)
            if answer.id == INSTALL_ACTIONS.dev.id or answer.id == INSTALL_ACTIONS.prod.id then
                callback(answer.id)
            end
        end,
    })

    menu:mount()
end

--- Input for entering package name to be installed
-- @param callback - function used after user enters the package name
M.display_install_input = function(callback)
    local input = Input({
        relative = "cursor",
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
        border = {
            style = "rounded",
            highlight = "Normal",
            text = {
                top = " Enter Package Name ",
                top_align = "left",
            },
        },
    }, {
        prompt = "> ",
        on_submit = function(package_name)
            callback(package_name)
        end,
    })

    input:mount()
end

--- Menu for selecting another version for the package
-- @param options.callback - function to use after the action has finished
-- @param options.package_name - string used to identify the package
M.display_change_version_menu = function(options)
    local menu = Menu({
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
    }, {
        lines = options.menu_items,
        keymap = {
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>", "<Space>" },
        },
        on_submit = function(answer)
            local command = utils.get_command.change_version(options.package_name, answer.text)

            utils.loading.start("|  Installing " .. options.package_name .. "@" .. answer.text)

            utils.job({
                command = command,
                on_success = function()
                    options.on_success()

                    utils.loading.stop()
                end,
                on_error = function()
                    utils.loading.stop()
                end,
            })
        end,
    })

    menu:mount()
end

return M
