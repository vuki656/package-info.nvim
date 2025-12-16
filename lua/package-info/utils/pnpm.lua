local constants = require("package-info.utils.constants")
local config = require("package-info.config")
local clean_version = require("package-info.helpers.clean_version")

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

---@class CreateVirtualTextInput
---@field current string
---@field latest string|boolean

---@param input CreateVirtualTextInput
M.create_pnpm_virtual_text = function(input)
    local is_outdated = input.latest and input.current ~= input.latest or false
    return {
        group = is_outdated and constants.HIGHLIGHT_GROUPS.outdated or constants.HIGHLIGHT_GROUPS.up_to_date,
        icon = is_outdated and config.options.icons.style.outdated or config.options.icons.style.up_to_date,
        version = clean_version(input.current) .. (is_outdated and (" - " .. input.latest) or ""),
    }
end

return M
