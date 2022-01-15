local logger = require("package-info.utils.logger")

local M = {
    -- TODO: rename to virtual_text_displayed
    --- If true the virtual text has been displayed
    displayed = false,
    --- If true the current buffer is package json, with content and correct format
    loaded = false,
}

M.is_loaded = function()
    if not M.loaded then
        logger.warn("Not in valid package.json file")

        return false
    end

    return true
end

M.buffer = {
    id = nil,
    --- Set the buffer id to current buffer id
    -- @return nil
    save = function()
        M.buffer.id = vim.fn.bufnr()
    end,
}

M.last_run = {
    time = nil,
    --- Update M.last_run.time to now in milliseconds
    -- @return nil
    update = function()
        M.last_run.time = os.time()
    end,
    --- Determine if the next run should be skipped
    -- Skip if there was a run within the past hour
    -- @return boolean
    should_skip = function()
        local HOUR_IN_SECONDS = 3600

        if M.last_run.time == nil then
            return false
        end

        return os.time() < M.last_run.time + HOUR_IN_SECONDS
    end,
}

M.namespace = {
    id = nil,
    --- Registers plugin specific namespace
    -- @return nil
    register = function()
        M.namespace.id = vim.api.nvim_create_namespace("package-info")
    end,
}

return M
