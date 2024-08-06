local json_parser = require("package-info.libs.json_parser")
local state = require("package-info.state")
local clean_version = require("package-info.helpers.clean_version")

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

M.parse_buffer = function()
    local buffer_lines = vim.api.nvim_buf_get_lines(state.buffer.id, 0, -1, false)
    local buffer_json_value = json_parser.decode(table.concat(buffer_lines))

    local intersection = intersect(buffer_json_value["devDependencies"] or {}, buffer_json_value["dependencies"] or {})
    local all_dependencies_json =
        vim.tbl_extend("force", {}, buffer_json_value["devDependencies"] or {}, buffer_json_value["dependencies"] or {})

    local installed_dependencies = {}

    for name, version in pairs(all_dependencies_json) do
        if intersection[name] ~= nil then
            installed_dependencies[name] = {
                current = "[ERROR] DEPENDENCY IS DUPLICATED",
            }
        else
            installed_dependencies[name] = {
                current = clean_version(version),
            }
        end
    end

    state.buffer.lines = buffer_lines
    state.dependencies.installed = installed_dependencies
end

return M
