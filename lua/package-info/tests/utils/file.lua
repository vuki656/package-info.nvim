local M = {}

--- Create a file under the given path
-- @param name: path with file name to create
-- @return nil
M.create = function(name)
    local file = io.open(name, "w")

    file:close()
end

--- Delete a file under the given path
-- @param name: path with file name to delete
-- @return nil
M.delete = function(name)
    os.remove(name)
end

return M
