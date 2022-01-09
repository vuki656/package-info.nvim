--- Converts a nullish value to a boolean
-- @param value?: string | number - value to check
-- @return boolean
return function(value)
    if type(value) == "string" and value == "" then
        return false
    end

    if value == nil then
        return false
    end

    return true
end
