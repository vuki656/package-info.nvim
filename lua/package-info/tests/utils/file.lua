local M = {}

--- Creata generic package.json file
-- @param props: table? - possible options
-- {
--     go: boolean? - if true, goes to package.json instantly after creation
-- }
M.create_package_json = function(props)
    local path = "package.json"

    local file = io.open(path, "w")

    file:write([[
        {
            "name": "repo-name",
            "scripts": {
                "lint": "eslint ./*"
            },
            "dependencies": {
                "react": "16.0.0",
                "nextjs": "16.0.0"
            },
            "devDependencies": {
                "eslint": "^8.0.0"
            }
        }
    ]])

    file:close()

    if props.go then
        M.go(path)
    end
end

M.delete_package_json = function()
    os.remove("package.json")
end

--- Create a file under the given path
-- @param path: string path with file name to create
-- @param content: string? - content to put in the file
-- @param go_to_file: boolean? - if true, switch to the created file right away
-- @return nil
M.create = function(path, content, go_to_file)
    local file = io.open(path, "w")

    if content ~= nil then
        file:write(content)
    end

    file:close()

    if go_to_file then
        M.go(path)
    end
end

--- Go to a file under the given path
-- @param path: path with file name to go to
-- @return nil
M.go = function(path)
    vim.cmd("find " .. path)
end

--- Delete a file under the given path
-- @param path: path with file name to delete
-- @return nil
M.delete = function(path)
    os.remove(path)
end

return M
