-- FIXME: Sometimes randomly fails

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")
local constants = require("package-info.utils.constants")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Core set_virtual_text", function()
    before_each(function()
        reset.all()
    end)

    before_each(function()
        reset.all()
    end)

    it("should set the virtual text in the correct position", function()
        local package_json = file.create_package_json({ go = true })
        local dependency = package_json.dependencies.eslint

        config.setup()
        core.load_plugin()

        core.__set_virtual_text({
            [dependency.name] = {
                latest = dependency.version.latest,
                current = dependency.version.current,
            },
        }, dependency.position + 1, dependency.name)

        local virtual_text_positions = vim.api.nvim_buf_get_extmarks(state.buffer.id, state.namespace.id, 0, -1, {})

        assert.are.equals(virtual_text_positions[1][2], dependency.position)

        file.delete_package_json()
    end)

    it("should set the virtual text with no icon if icons are disabled", function()
        local package_json = file.create_package_json({ go = true })
        local dependency = package_json.dependencies.eslint

        config.setup({ icons = { enable = false } })
        core.load_plugin()

        local dependency_metadata = core.__set_virtual_text({
            [dependency.name] = {
                latest = dependency.version.latest,
                current = dependency.version.current,
            },
        }, dependency.position + 1, dependency.name)

        assert.are.equals("", dependency_metadata.icon)

        file.delete_package_json()
    end)

    it("shouldn't set the virtual text for up to date dependencies if hide_up_to_date is true", function()
        local package_json = file.create_package_json({ go = true })
        local dependency = package_json.dependencies.next

        config.setup({ hide_up_to_date = true })
        core.load_plugin()

        local dependency_metadata = core.__set_virtual_text({
            [dependency.name] = {
                latest = dependency.version.latest,
                current = dependency.version.current,
            },
        }, dependency.position + 1, dependency.name)

        assert.are.equals("", dependency_metadata.icon)
        assert.are.equals("", dependency_metadata.version)

        file.delete_package_json()
    end)

    it("should display the latest version if the current one is out of date", function()
        local package_json = file.create_package_json({ go = true })
        local dependency = package_json.dependencies.react

        config.setup()
        core.load_plugin()

        local dependency_metadata = core.__set_virtual_text({
            [dependency.name] = {
                latest = dependency.version.latest,
                current = dependency.version.current,
            },
        }, dependency.position + 1, dependency.name)

        assert.are.equals(config.options.icons.style.outdated, dependency_metadata.icon)
        assert.are.equals(dependency.version.latest, dependency_metadata.version)
        assert.are.equals(constants.HIGHLIGHT_GROUPS.outdated, dependency_metadata.group)

        file.delete_package_json()
    end)

    it("should display the existing version when the latest is the same", function()
        local package_json = file.create_package_json({ go = true })
        local dependency = package_json.dependencies.next

        config.setup()
        core.load_plugin()

        local dependency_metadata = core.__set_virtual_text({
            [dependency.name] = {
                latest = dependency.version.latest,
                current = dependency.version.current,
            },
        }, dependency.position + 1, dependency.name)

        assert.are.equals(config.options.icons.style.up_to_date, dependency_metadata.icon)
        assert.are.equals(dependency.version.current, dependency_metadata.version)
        assert.are.equals(constants.HIGHLIGHT_GROUPS.up_to_date, dependency_metadata.group)

        file.delete_package_json()
    end)
end)
