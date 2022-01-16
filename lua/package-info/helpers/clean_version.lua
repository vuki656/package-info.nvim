--- Strips ^ from version
-- @param value: string - value from which to strip ^ from
-- @return string?
return function(value)
    if value == nil then
        return nil
    end

    return value:gsub("%^", "")
end
