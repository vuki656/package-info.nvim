-- FILE DESCRIPTION: Plugin global state

----------------------------------------------------------------------------
---------------------------------- MODULE ----------------------------------
----------------------------------------------------------------------------

local M = {}

M.namespace = {
    id = "",
    register = function()
        M.namespace.id = vim.api.nvim_create_namespace("package-ui")
    end,
}

M.buffer = {}

return M
