local expect = MiniTest.expect

local find_upwards = require("package-info.utils.find-upwards")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

--- Turns the given path into the value find upwards returns
-- @param path: string - path to convert
-- @return string
local absolute = function(path)
    return (vim.fn.simplify(vim.fn.fnamemodify(path, ":p")):gsub("(.)/$", "%1"))
end

--- Creates a package directory nested inside a random root directory
-- @return table - root and nested directory paths
local create_directories = function()
    local root = vim.fn.fnamemodify(file.generate_file(), ":h")
    local nested = root .. "/packages/website"

    vim.fn.mkdir(nested, "p")

    return { root = root, nested = nested }
end

local matches = function(name)
    return function(directory)
        return vim.fn.filereadable(directory .. "/" .. name) == 1
    end
end

T["should return the start directory when it matches"] = function()
    local directories = create_directories()

    file.create({ name = directories.nested .. "/pnpm-lock.yaml" })

    local match = find_upwards(directories.nested, matches("pnpm-lock.yaml"))

    expect.equality(match, absolute(directories.nested))
end

T["should return the closest matching directory above the start directory"] = function()
    local directories = create_directories()

    file.create({ name = directories.root .. "/pnpm-lock.yaml" })

    local match = find_upwards(directories.nested, matches("pnpm-lock.yaml"))

    expect.equality(match, absolute(directories.root))
end

T["should return nil when no directory matches"] = function()
    local directories = create_directories()

    local match = find_upwards(directories.nested, matches("pnpm-lock.yaml"))

    expect.equality(match, nil)
end

T["should not walk past the git root"] = function()
    local directories = create_directories()

    file.create({ name = directories.root .. "/.git" })
    file.create({ name = "./temp/yarn.lock" })

    local match = find_upwards(directories.nested, matches("yarn.lock"))

    file.delete("./temp/yarn.lock")

    expect.equality(match, nil)
end

T["should return nil when there is no start directory"] = function()
    expect.equality(find_upwards(nil, matches("yarn.lock")), nil)
    expect.equality(find_upwards("", matches("yarn.lock")), nil)
end

return T
