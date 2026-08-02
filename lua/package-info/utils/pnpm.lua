local find_upwards = require("package-info.utils.find-upwards")

local WORKSPACE_FILE = "pnpm-workspace.yaml"

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

---Finds the workspace file the given directory belongs to
---@param directory string - directory to search from, upwards
---@return string? - path of the workspace file
M.workspace_path = function(directory)
    local workspace_directory = find_upwards(directory, function(candidate)
        return vim.fn.filereadable(candidate .. "/" .. WORKSPACE_FILE) == 1
    end)

    if workspace_directory == nil then
        return nil
    end

    return workspace_directory .. "/" .. WORKSPACE_FILE
end

return M
