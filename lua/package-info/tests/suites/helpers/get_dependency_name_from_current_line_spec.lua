local expect = MiniTest.expect

local core = require("package-info.core")
local logger = require("package-info.utils.logger")
local get_dependency_name_from_current_line = require("package-info.helpers.get_dependency_name_from_current_line")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")
local spy = require("package-info.tests.utils.spy")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should get the name correctly"] = function()
    local package_json = file.create_package_json({ go = true })

    core.load_plugin()

    vim.cmd(tostring(package_json.dependencies.eslint.position))

    local dependency_name = get_dependency_name_from_current_line()

    file.delete(package_json.path)

    expect.equality(dependency_name, package_json.dependencies.eslint.name)
end

T["should return nil if no valid dependency is on the current line"] = function()
    local package_json = file.create_package_json({ go = true })

    core.load_plugin()

    local warn = spy.on(logger, "warn")

    vim.cmd("999")

    local dependency_name = get_dependency_name_from_current_line()

    expect.equality(dependency_name, nil)
    expect.equality(warn.count, 1)
    expect.equality(spy.was_called_with(warn, "No valid dependency on current line"), true)

    file.delete(package_json.path)
end

return T
