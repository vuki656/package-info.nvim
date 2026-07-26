--- Checks if the given path points to a real file on disk
-- @param path: string - path to check
-- @return boolean
return function(path)
    if path == nil or path == "" then
        return false
    end

    if string.match(path, "^%a[%w+.-]*://") then
        return false
    end

    return vim.fn.isdirectory(vim.fn.fnamemodify(path, ":p:h")) == 1
end
