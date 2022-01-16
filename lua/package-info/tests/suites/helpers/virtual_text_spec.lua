local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")
local constants = require("package-info.utils.constants")
local config = require("package-info.config")
local virtual_text = require("package-info.helpers.virtual_text")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

describe("Helpers virtual_text", function()
    describe("display", function()
        before_each(function()
            reset.all()
        end)

        after_each(function()
            reset.all()
        end)

        it("should be called for each dependency in package.json", function()
            local package_json = file.create_package_json({ go = true })

            config.setup()
            core.load_plugin()

            spy.on(virtual_text, "__display_on_line")

            virtual_text.display()

            file.delete(package_json.path)

            assert.spy(virtual_text.__display_on_line).was_called(package_json.total_count)
            assert.is_true(state.is_virtual_text_displayed)
        end)
    end)

    describe("virtual_text clear", function()
        before_each(function()
            reset.all()
        end)

        after_each(function()
            reset.all()
        end)

        it("shouldn't run if nothing is displayed", function()
            spy.on(vim.api, "nvim_buf_clear_namespace")

            virtual_text.clear()

            assert.spy(vim.api.nvim_buf_clear_namespace).was_called(0)
        end)

        it("should clear all existing virtual text", function()
            local package_json = file.create_package_json({ go = true })

            spy.on(vim.api, "nvim_buf_clear_namespace")

            config.setup()
            core.load_plugin()
            virtual_text.display()
            virtual_text.clear()

            local virtual_text_positions = vim.api.nvim_buf_get_extmarks(state.buffer.id, state.namespace.id, 0, -1, {})

            file.delete(package_json.path)

            assert.spy(vim.api.nvim_buf_clear_namespace).was_called(1)
            assert.is_true(vim.tbl_isempty(virtual_text_positions))
        end)
    end)

    describe("display_on_line", function()
        before_each(function()
            reset.all()
        end)

        after_each(function()
            reset.all()
        end)

        it("should set the virtual text in the correct position", function()
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

            assert.are.equals(virtual_text_positions[1][2], dependency.position)
        end)

        it("should set the virtual text with no icon if icons are disabled", function()
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

            assert.are.equals("", dependency_metadata.icon)
        end)

        it("shouldn't set the virtual text for up to date dependencies if hide_up_to_date is true", function()
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

            assert.are.equals("", dependency_metadata.icon)
            assert.are.equals("", dependency_metadata.version)
        end)

        it("should display the latest version if the current one is out of date", function()
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

            assert.are.equals(config.options.icons.style.outdated, dependency_metadata.icon)
            assert.are.equals(dependency.version.latest, dependency_metadata.version)
            assert.are.equals(constants.HIGHLIGHT_GROUPS.outdated, dependency_metadata.group)
        end)

        it("should display the existing version when the latest is the same", function()
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

            assert.are.equals(config.options.icons.style.up_to_date, dependency_metadata.icon)
            assert.are.equals(dependency.version.current, dependency_metadata.version)
            assert.are.equals(constants.HIGHLIGHT_GROUPS.up_to_date, dependency_metadata.group)
        end)
    end)
end)
