local constants = require("package-info.utils.constants")

--- Register given command when the event fires
-- @param event: string - event that will trigger the autocommand
-- @param command: string - command to fire when the event is triggered
-- @param pattern: string|nil - pattern to match the event against, defaults to package.json
return function(event, command, pattern)
    vim.api.nvim_create_autocmd(event, {
        group = vim.api.nvim_create_augroup(constants.AUTOGROUP, { clear = false }),
        pattern = pattern or "package.json",
        command = command,
    })
end
