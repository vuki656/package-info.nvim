--- Turns the given path into an absolute one without a trailing slash
-- @param path: string - path to normalize
-- @return string
local normalize = function(path)
    local absolute_path = vim.fn.simplify(vim.fn.fnamemodify(path, ":p"))

    return (absolute_path:gsub("(.)/$", "%1"))
end

--- Returns the last directory the walk is allowed to check
-- @param directory: string - directory the walk starts from
-- @return string? - git root, home directory or nil for the filesystem root
local get_boundary = function(directory)
    local git_path = vim.fs.find(".git", { upward = true, path = directory, limit = 1 })[1]

    if git_path then
        return normalize(vim.fs.dirname(git_path))
    end

    local home_directory = vim.fn.expand("~")

    if home_directory ~= "" and vim.startswith(directory, normalize(home_directory)) then
        return normalize(home_directory)
    end

    return nil
end

--- Walks up from the given directory and returns the first one the matcher accepts
-- The walk stops at the git root, the home directory or the filesystem root
-- @param start_directory: string - directory to start the walk from
-- @param matcher: function - called with every directory, stops the walk when it returns true
-- @return string? - absolute path of the matched directory
return function(start_directory, matcher)
    if start_directory == nil or start_directory == "" then
        return nil
    end

    local directory = normalize(start_directory)
    local boundary = get_boundary(directory)

    while true do
        if matcher(directory) then
            return directory
        end

        if directory == boundary or vim.fs.dirname(directory) == directory then
            return nil
        end

        directory = vim.fs.dirname(directory)
    end
end
