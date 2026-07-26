return function(value)
    return string.match(value, "^[%w_%.%-%+%s|=<>*~%^/:@#]+$") ~= nil
end
