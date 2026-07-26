local M = {}

M.find_catalog_name = function(name)
    return string.match(name, "catalog:(.+)")
end

---Checks for pnpm catalog pattern
---@param value string - value to check for catalog pattern
---@return boolean
M.is_catalog = function(value)
    return string.find(value, "catalog:") ~= nil
end

M.is_workspace = function()
    return vim.fn.filereadable(M.workspace_path()) == 1
end

M.workspace_path = function()
    return vim.fn.getcwd() .. "/pnpm-workspace.yaml"
end

return M
