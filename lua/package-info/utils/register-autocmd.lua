local constants = require("package-info.utils.constants")
local group = vim.api.nvim_create_augroup(constants.AUTOGROUP, { clear = true })

---Register given command when the event fires
---@param event string: event that will trigger the autocommand
---@param pattern string|array: pattern(s) that need to be fulfilled for the `autocmd` to trigger
---@param command string: command to fire when the event is triggered
return function(event, pattern, command)
    vim.api.nvim_create_autocmd(event, {
        pattern = pattern,
        group = group,
        command = command,
    })
end
