local utils = require("package-info.utils")
local Menu = utils.prequire("nui.menu")
local Input = utils.prequire("nui.input")

local constants = require("package-info.constants")

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
    local function on_submit(choice)
        choice = choice.text or choice
        if choice == "Cancel" then
            return options.on_cancel()
        end
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
    end

    if not Menu or not Input then
        return vim.ui.select({ "Confirm", "Cancel" }, { prompt = "Do you want to" .. options.title .. "?:" }, on_submit)
    end

    Menu({
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
        on_submit = on_submit,
    }):mount()
end

--- Menu to choose the type of dependency to be installed
M.display_install_menu = function(callback)
    local function on_submit(dependency_type)
        dependency_type = dependency_type.text or dependency_type
        if dependency_type == "Cancel" then
            return
        end
        local id
        for _, value in pairs(INSTALL_ACTIONS) do
            if value.text == dependency_type then
                id = value.id
            end
        end
        callback(id)
    end

    if not Menu or not Input then
        return vim.ui.select({ "Production", "Development", "Cancel" }, { prompt = "" }, on_submit)
    end

    Menu({
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
            Menu.item("Production"),
            Menu.item("Development"),
            Menu.item("Cancel"),
        },
        keymap = {
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>", "<Space>" },
        },
        on_submit = on_submit,
    }):mount()
end

--- Input for entering package name to be installed
-- @param callback - function used after user enters the package name
M.display_install_input = function(callback)
    local function on_submit(package)
        callback(package)
    end

    if not Menu or not Input then
        return vim.ui.input({ prompt = "Enter Package Name: " }, on_submit)
    end

    Input({
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
        on_submit = on_submit,
    }):mount()
end

--- Menu for selecting another version for the package
-- @param options.callback - function to use after the action has finished
-- @param options.package_name - string used to identify the package
M.display_change_version_menu = function(options)
    local function on_submit(version)
        version = version.text or version
        local command = utils.get_command.change_version(options.package_name, version)

        utils.loading.start("|  Installing " .. options.package_name .. "@" .. version)

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
    end

    if not Menu or not Input then
        return vim.ui.select(options.menu_items, { prompt = "Select a version: " }, on_submit)
    end

    local versions = {}
    for _, version in ipairs(options.menu_items) do
        table.insert(versions, Menu.item(version))
    end

    Menu({
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
        lines = versions,
        keymap = {
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>", "<Space>" },
        },
        on_submit = on_submit,
    }):mount()
end

return M
