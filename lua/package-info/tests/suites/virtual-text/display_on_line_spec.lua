local expect = MiniTest.expect

local core = require("package-info.core")
local state = require("package-info.state")
local constants = require("package-info.utils.constants")
local config = require("package-info.config")
local virtual_text = require("package-info.virtual_text")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should set the virtual text in the correct position"] = function()
    local package_json = file.create_package_json({ go = true })
    local dependency = package_json.dependencies.eslint

    config.setup()
    core.load_plugin()

    state.dependencies.outdated = {
        [dependency.name] = {
            latest = dependency.version.latest,
            current = dependency.version.current,
        },
    }

    virtual_text.__display_on_line(dependency.position + 1, dependency.name)

    local virtual_text_positions = vim.api.nvim_buf_get_extmarks(state.buffer.id, state.namespace.id, 0, -1, {})

    file.delete(package_json.path)

    expect.equality(virtual_text_positions[1][2], dependency.position)
end

T["should set the virtual text with no icon if icons are disabled"] = function()
    local package_json = file.create_package_json({ go = true })
    local dependency = package_json.dependencies.eslint

    config.setup({ icons = { enable = false } })
    core.load_plugin()

    state.dependencies.outdated = {
        [dependency.name] = {
            latest = dependency.version.latest,
            current = dependency.version.current,
        },
    }

    local dependency_metadata = virtual_text.__display_on_line(dependency.position + 1, dependency.name)

    file.delete(package_json.path)

    expect.equality(dependency_metadata.icon, "")
end

T["shouldn't set the virtual text for up to date dependencies if hide_up_to_date is true"] = function()
    local package_json = file.create_package_json({ go = true })
    local dependency = package_json.dependencies.next

    config.setup({ hide_up_to_date = true })
    core.load_plugin()

    state.dependencies.outdated = {
        [dependency.name] = {
            latest = dependency.version.latest,
            current = dependency.version.current,
        },
    }

    local dependency_metadata = virtual_text.__display_on_line(dependency.position + 1, dependency.name)

    file.delete(package_json.path)

    expect.equality(dependency_metadata.icon, "")
    expect.equality(dependency_metadata.version, "")
end

T["should display the latest version if the current one is out of date"] = function()
    local package_json = file.create_package_json({ go = true })
    local dependency = package_json.dependencies.react

    config.setup()
    core.load_plugin()

    state.dependencies.outdated = {
        [dependency.name] = {
            latest = dependency.version.latest,
            current = dependency.version.current,
        },
    }

    local dependency_metadata = virtual_text.__display_on_line(dependency.position + 1, dependency.name)

    file.delete(package_json.path)

    expect.equality(dependency_metadata.icon, config.options.icons.style.outdated)
    expect.equality(dependency_metadata.version, dependency.version.latest)
    expect.equality(dependency_metadata.group, constants.HIGHLIGHT_GROUPS.outdated)
end

T["should display the existing version when the latest is the same"] = function()
    local package_json = file.create_package_json({ go = true })
    local dependency = package_json.dependencies.next

    config.setup()
    core.load_plugin()

    state.dependencies.outdated = {
        [dependency.name] = {
            latest = dependency.version.latest,
            current = dependency.version.current,
        },
    }

    local dependency_metadata = virtual_text.__display_on_line(dependency.position + 1, dependency.name)

    file.delete(package_json.path)

    expect.equality(dependency_metadata.icon, config.options.icons.style.up_to_date)
    expect.equality(dependency_metadata.version, dependency.version.current)
    expect.equality(dependency_metadata.group, constants.HIGHLIGHT_GROUPS.up_to_date)
end

T["should display error diagnostics"] = function()
    local package_json = file.create_package_json({ go = true })
    local dependency = package_json.dependencies.next

    config.setup()
    core.load_plugin()

    state.dependencies.invalid = {
        [dependency.name] = {
            diagnostic = "BAD",
        },
    }

    local dependency_metadata = virtual_text.__display_on_line(dependency.position + 1, dependency.name)

    file.delete(package_json.path)

    expect.equality(dependency_metadata.icon, config.options.icons.style.invalid)
    expect.equality(dependency_metadata.version, "BAD")
    expect.equality(dependency_metadata.group, constants.HIGHLIGHT_GROUPS.invalid)
end

return T
