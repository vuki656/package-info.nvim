local state = require("package-info.state")

local has_latest = function(entry)
    return type(entry) == "table" and entry.latest ~= nil
end

local pick_entry = function(entries)
    for _, entry in ipairs(entries) do
        if has_latest(entry) and entry.dependent ~= nil and entry.dependent == state.buffer.package_name then
            return entry
        end
    end

    for _, entry in ipairs(entries) do
        if has_latest(entry) then
            return entry
        end
    end

    return nil
end

return function(outdated_dependencies)
    if type(outdated_dependencies) ~= "table" then
        return {}
    end

    local normalized = {}

    for dependency_name, entry in pairs(outdated_dependencies) do
        if type(entry) == "table" and entry[1] ~= nil then
            normalized[dependency_name] = pick_entry(entry)
        elseif has_latest(entry) then
            normalized[dependency_name] = entry
        end
    end

    return normalized
end
