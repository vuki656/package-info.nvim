local M = {}

--- Create a file under the given path
-- @param name: path with file name to create
-- @param content?: content to put in the file
-- @return nil
M.create = function(name, content)
    local file = io.open(name, "w")

    if content ~= nil then
        file:write(content)
    end

    file:close()
end

--- Go to a file under the given path
-- @param name: path with file name to go to
-- @return nil
M.go = function(name)
    vim.cmd("find " .. name)
end

--- Delete a file under the given path
-- @param name: path with file name to delete
-- @return nil
M.delete = function(name)
    os.remove(name)
end

return M
