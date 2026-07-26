local M = {}

local reverts = {}

--- Replace a module function with a counting wrapper
-- @param module: table - table holding the function
-- @param key: string - name of the function on the module
-- @return table - record with a call count and the arguments of every call
M.on = function(module, key)
    local original = module[key]
    local record = { count = 0, calls = {} }

    module[key] = function(...)
        record.count = record.count + 1
        table.insert(record.calls, { ... })

        return original(...)
    end

    table.insert(reverts, function()
        module[key] = original
    end)

    return record
end

--- Check if a recorded function was ever called with the given arguments
-- @param record: table - record returned by M.on
-- @return boolean
M.was_called_with = function(record, ...)
    local expected = { ... }

    for _, call in ipairs(record.calls) do
        if vim.deep_equal(call, expected) then
            return true
        end
    end

    return false
end

--- Restore every function replaced by M.on
-- @return nil
M.revert_all = function()
    for index = #reverts, 1, -1 do
        reverts[index]()
        reverts[index] = nil
    end
end

return M
