local M = {
    displayed = false,
}

M.buffer = {
    id = nil,
    save = function()
        M.buffer.id = vim.fn.bufnr()
    end,
}

M.last_run = {
    time = nil,
    update = function()
        M.last_run.time = os.time()
    end,
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
    register = function()
        M.namespace.id = vim.api.nvim_create_namespace("package-info")
    end,
}

return M
