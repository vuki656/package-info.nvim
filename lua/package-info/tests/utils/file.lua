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
-- @param props: table? -- contains
-- {
--      path: string path with file name to create
--      content: string? - content to put in the file
--      go: boolean? - if true, switch to the created file right away
-- }
-- @return nil
M.create = function(props)
    local file = io.open(props.path, "w")

    if props.content ~= nil then
        file:write(props.content)
    end

    file:close()

    if props.go then
        M.go(props.path)
    end

    return { path = props.path }
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
