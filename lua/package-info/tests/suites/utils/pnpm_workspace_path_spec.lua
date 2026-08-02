local expect = MiniTest.expect

local pnpm = require("package-info.utils.pnpm")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

--- Creates a package directory nested inside a random root directory
-- @return table - root and nested directory paths
local create_directories = function()
    local root = vim.fn.fnamemodify(file.generate_file(), ":h")
    local nested = root .. "/packages/website"

    vim.fn.mkdir(nested, "p")

    return { root = root, nested = nested }
end

T["should return the workspace file above the package directory"] = function()
    local directories = create_directories()

    file.create({ name = directories.root .. "/pnpm-workspace.yaml" })

    local workspace_path = pnpm.workspace_path(directories.nested)

    local expected = vim.fn.simplify(vim.fn.fnamemodify(directories.root .. "/pnpm-workspace.yaml", ":p"))

    expect.equality(workspace_path, expected)
end

T["should return nil when there is no workspace file"] = function()
    local directories = create_directories()

    expect.equality(pnpm.workspace_path(directories.nested), nil)
end

return T
