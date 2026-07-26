local state = require("package-info.state")
local clean_version = require("package-info.helpers.clean_version")
local is_valid_version_syntax = require("package-info.helpers.is_valid_version_syntax")

local M = {}

local function createKeySet(tbl)
    local keySet = {}
    for key in pairs(tbl) do
        keySet[key] = true
    end
    return keySet
end

local function intersectKeySets(set1, set2)
    local intersection = {}
    for key in pairs(set1) do
        if set2[key] then
            intersection[key] = true
        end
    end
    return intersection
end

local function intersect(t1, t2)
    local s1 = createKeySet(t1)
    local s2 = createKeySet(t2)
    return intersectKeySets(s1, s2)
end

local function as_table(value)
    if type(value) ~= "table" then
        return {}
    end

    return value
end

M.parse_buffer = function()
    local buffer_lines = vim.api.nvim_buf_get_lines(state.buffer.id, 0, -1, false)
    local buffer_json_value = as_table(vim.json.decode(table.concat(buffer_lines)))

    local dev_dependencies = as_table(buffer_json_value["devDependencies"])
    local dependencies = as_table(buffer_json_value["dependencies"])

    local intersection = intersect(dev_dependencies, dependencies)
    local all_dependencies_json = vim.tbl_extend("force", {}, dev_dependencies, dependencies)

    local installed_dependencies = {}
    local errored_dependencies = {}

    for name, version in pairs(all_dependencies_json) do
        local has_version_string = type(version) == "string"

        installed_dependencies[name] = {
            current = has_version_string and clean_version(version) or nil,
        }
        if intersection[name] ~= nil then
            errored_dependencies[name] = {
                diagnostic = "DUPLICATED",
            }
        elseif not has_version_string or not is_valid_version_syntax(version) then
            errored_dependencies[name] = {
                diagnostic = "INVALID VERSION",
            }
        end
    end

    local package_name = buffer_json_value["name"]

    state.buffer.lines = buffer_lines
    state.buffer.package_name = type(package_name) == "string" and package_name or nil
    state.dependencies.installed = installed_dependencies
    state.dependencies.invalid = errored_dependencies
end

return M
