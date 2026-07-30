local expect = MiniTest.expect

local config = require("package-info.config")
local core = require("package-info.core")
local refresh = require("package-info.helpers.refresh")
local show_action = require("package-info.actions.show")
local state = require("package-info.state")
local virtual_text = require("package-info.virtual_text")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should invalidate the cache"] = function()
    local package_json = file.create_package_json({ go = true })

    config.setup()
    core.load_plugin()

    state.last_run.update()

    refresh()

    file.delete(package_json.path)

    expect.equality(state.last_run.time, nil)
end

--- Replace show.run with a recorder so no npm outdated process outlives the case
-- @return table - record with a call count and the options of the last call
local record_show_run = function()
    local original = show_action.run
    local record = { count = 0, options = nil }

    show_action.run = function(options)
        record.count = record.count + 1
        record.options = options
    end

    record.revert = function()
        show_action.run = original
    end

    return record
end

T["should not refetch if the virtual text is hidden"] = function()
    local package_json = file.create_package_json({ go = true })

    config.setup()
    core.load_plugin()

    local run = record_show_run()

    state.is_virtual_text_displayed = false

    refresh()

    run.revert()
    file.delete(package_json.path)

    expect.equality(run.count, 0)
end

T["should refetch if the virtual text is displayed"] = function()
    local package_json = file.create_package_json({ go = true })

    config.setup()
    core.load_plugin()

    virtual_text.display()

    local run = record_show_run()

    refresh()

    run.revert()
    file.delete(package_json.path)

    expect.equality(run.count, 1)
    expect.equality(run.options, { force = true })
end

return T
