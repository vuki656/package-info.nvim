local M = {}

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
