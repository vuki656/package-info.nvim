local expect = MiniTest.expect

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")
local virtual_text = require("package-info.virtual_text")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")
local spy = require("package-info.tests.utils.spy")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["shouldn't run if virtual text is not displayed"] = function()
    local clear_namespace = spy.on(vim.api, "nvim_buf_clear_namespace")

    virtual_text.clear()

    expect.equality(clear_namespace.count, 0)
end

T["should clear all existing virtual text"] = function()
    local package_json = file.create_package_json({ go = true })

    local clear_namespace = spy.on(vim.api, "nvim_buf_clear_namespace")

    config.setup()
    core.load_plugin()
    virtual_text.display()
    virtual_text.clear()

    local virtual_text_positions = vim.api.nvim_buf_get_extmarks(state.buffer.id, state.namespace.id, 0, -1, {})

    file.delete(package_json.path)

    expect.equality(clear_namespace.count, 1)
    expect.equality(vim.tbl_isempty(virtual_text_positions), true)
end

return T
