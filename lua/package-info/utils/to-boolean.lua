--- Converts a nullish value to a boolean
-- @param value?: string | number | table - value to check
-- @return boolean
return function(value)
    if value == nil then
        return false
    end

    if type(value) == "table" and vim.tbl_isempty(value) then
        return false
    end

    if type(value) == "string" and value == "" then
        return false
    end

    return true
end
