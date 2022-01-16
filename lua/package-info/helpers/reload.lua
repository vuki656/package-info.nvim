local parser = require("package-info.parser")
local core = require("package-info.core")
local state = require("package-info.state")

--- Reloads the buffer if it's package.json
-- @return nil
local reload_buffer = function()
    local current_buffer_number = vim.fn.bufnr()

    if current_buffer_number == state.buffer.id then
        local view = vim.fn.winsaveview()

        vim.cmd("edit")
        vim.fn.winrestview(view)
    end
end

--- Rereads the current buffer value and reloads the buffer
-- @return nil
return function()
    if not state.is_loaded then
        return
    end

    reload_buffer()

    parser.parse_buffer()

    if state.virtual_text.is_displayed then
        state.virtual_text.clear()

        core.display_virtual_text()
    end

    reload_buffer()
end
