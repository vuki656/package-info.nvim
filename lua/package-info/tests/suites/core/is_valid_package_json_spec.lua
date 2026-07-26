local expect = MiniTest.expect

local core = require("package-info.core")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should return true for valid package.json"] = function()
    local package_json = file.create_package_json({ go = true })

    local is_valid = core.__is_valid_package_json()

    file.delete(package_json.path)

    expect.equality(is_valid, true)
end

T["should return false if buffer empty"] = function()
    local is_valid = core.__is_valid_package_json()

    expect.equality(is_valid, false)
end

T["should return false if file not called package.json"] = function()
    local path = "some_random_file_that_is_dead.txt"

    file.create({
        name = path,
        go = true,
    })

    local is_valid = core.__is_valid_package_json()

    file.delete(path)

    expect.equality(is_valid, false)
end

T["should return false if the buffer is not a file on disk"] = function()
    local buffer = vim.api.nvim_create_buf(true, false)

    vim.api.nvim_buf_set_name(buffer, "diffview:///home/user/project/.git/abc123/package.json")
    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { '{ "dependencies": { "react": "16.0.0" } }' })

    local is_valid = core.__is_valid_package_json()

    vim.cmd("edit void")
    vim.api.nvim_buf_delete(buffer, { force = true })

    expect.equality(is_valid, false)
end

T["should return false if json is invalid format"] = function()
    local package_json = file.create_package_json({
        content = '{ "name" = function () { }',
        go = true,
    })

    local is_valid = core.__is_valid_package_json()

    file.delete(package_json.path)

    expect.equality(is_valid, false)
end

return T
