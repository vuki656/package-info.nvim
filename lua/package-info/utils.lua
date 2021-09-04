M = {}

--- Checks if given string contains "error"
-- For now probably acceptable, but should be more precise
-- @param value - string to check
M.has_errors = function(value)
    local string_value = value

    if type(value) ~= "string" then
        string_value = table.concat(value)
    end

    return string.find(string_value, "error") ~= nil
end

return M
