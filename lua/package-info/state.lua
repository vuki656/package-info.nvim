local logger = require("package-info.utils.logger")

local M = {
    --- If true the current buffer is package json, with content and correct format
    loaded = false,
}

M.virtual_text = {
    is_displayed = false,
}

M.is_loaded = function()
    if not M.loaded then
        logger.warn("Not in valid package.json file")

        return false
    end

    return true
end

M.dependencies = {
    -- Outdated dependencies from `npm outdated --json` as a list of
    -- [name]: {
    --     current: string
    --     latest: string
    -- }
    outdated = {},
    -- Installed dependencies from package.json as a list of
    -- ["dependency_name"] = {
    --     current: string - current package version,
    -- }
    installed = {},
}

M.buffer = {
    id = nil,
    -- String value of buffer from vim.api.nvim_buf_get_lines(state.buffer.id, 0, -1, false)
    lines = {},
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
    --- Creates plugin specific namespace
    -- @return nil
    create = function()
        M.namespace.id = vim.api.nvim_create_namespace("package-info")
    end,
}

return M
