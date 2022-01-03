--- Call the function if not nil
-- @param callback: function - function to try and call
return function(callback)
    if callback ~= nil then
        callback()
    end
end
