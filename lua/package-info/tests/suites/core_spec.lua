-- TODO: split into multiple files
-- TODO: figure out how to make the mocking for virtual text display more DRY
-- TODO: option passing to display_virtual_text is janky, see if it can be better in the core itself
-- TODO: assert color groups => makes sure the correct color is used

local spy = require("luassert.spy")

local core = require("package-info.core")
local state = require("package-info.state")
local config = require("package-info.config")
local constants = require("package-info.utils.constants")
local logger = require("package-info.utils.logger")

local file = require("package-info.tests.utils.file")

describe("Core", function()
    before_each(function()
        state.reset()
    end)

    describe("clean_version", function()
        it("should return cleaned version", function()
            local cleaned_version = core.__clean_version("^1.0.0")

            assert.are.equals("1.0.0", cleaned_version)
        end)

        it("should return nil if falsy value passed in", function()
            local cleaned_version = core.__clean_version(nil)

            assert.is_nil(cleaned_version)
        end)
    end)

    describe("is_valid_package_version", function()
        it("should return true if version is valid", function()
            local is_valid = core.__is_valid_package_version("1.0.0")

            assert.is_true(is_valid)
        end)

        it("should return false if version is invalid", function()
            local is_valid = core.__is_valid_package_version("test")

            assert.is_false(is_valid)
        end)
    end)

    describe("decode_json_string", function()
        it("should return nil if json is invalid", function()
            local json_value = core.__decode_json_string('{ l "name": "test" }')

            assert.is_nil(json_value)
        end)

        it("should decoded json if json is valid", function()
            local json_value = core.__decode_json_string('{ "name": "test" }')

            assert.are.same({ name = "test" }, json_value)
        end)
    end)

    describe("reload_buffer", function()
        it("should reload the buffer if it's package.json", function()
            local file_name = "package.json"

            file.create(file_name, '{ "name": "package" }')
            file.go(file_name)

            spy.on(vim, "cmd")
            spy.on(vim.fn, "winsaveview")
            spy.on(vim.fn, "winrestview")

            core.load_plugin()
            core.__reload_buffer()

            file.delete(file_name)

            assert.spy(vim.cmd).was_called(1)
            assert.spy(vim.cmd).was_called_with("edit")
            assert.spy(vim.fn.winsaveview).was_called(1)
            assert.spy(vim.fn.winrestview).was_called(1)
        end)

        it("shouldn't reload the buffer if it's not in package.json", function()
            spy.on(vim, "cmd")
            spy.on(vim.fn, "winsaveview")
            spy.on(vim.fn, "winrestview")

            core.load_plugin()
            core.__reload_buffer()

            assert.spy(vim.cmd).was_called(0)
            assert.spy(vim.fn.winsaveview).was_called(0)
            assert.spy(vim.fn.winrestview).was_called(0)
        end)
    end)

    describe("set_virtual_text", function()
        it("should set the virtual text in the correct position", function()
            local dependency = {
                position = 3,
                name = "react",
                version = {
                    current = "16.0.0",
                    latest = "18.0.0",
                },
            }

            -- Simulate dependancies being parsed
            core.__dependencies = {
                [dependency.name] = {
                    version = dependency.version,
                },
            }

            local file_name = "package.json"

            file.create(
                file_name,
                string.format(
                    [[
                    {
                        "dependencies": {
                            "%s": "%s"
                        }
                    }
                ]],
                    dependency.name,
                    dependency.version.current
                )
            )

            file.go(file_name)

            core.load_plugin()
            config.setup()

            core.__set_virtual_text(
                {
                    [dependency.name] = {
                        latest = dependency.version.latest,
                        current = dependency.version.latest,
                    },
                },
                -- In regular usage, we need to offset since it starts from 1
                dependency.position + 1,
                dependency.name
            )

            local virtual_text_positions = vim.api.nvim_buf_get_extmarks(state.buffer.id, state.namespace.id, 0, -1, {})

            assert.are.equals(virtual_text_positions[1][2], dependency.position)

            file.delete(file_name)
        end)

        it("should set the virtual text with no icon if icons are disabled", function()
            local dependency = {
                position = 3,
                name = "react",
                version = {
                    current = "16.0.0",
                    latest = "18.0.0",
                },
            }

            -- Simulate dependancies being parsed
            core.__dependencies = {
                [dependency.name] = {
                    version = dependency.version,
                },
            }

            local file_name = "package.json"

            file.create(
                file_name,
                string.format(
                    [[
                    {
                        "dependencies": {
                            "%s": "%s"
                        }
                    }
                    ]],
                    dependency.name,
                    dependency.version.current
                )
            )

            file.go(file_name)

            core.load_plugin()
            config.setup({ icons = { enable = false } })

            local dependency_metadata = core.__set_virtual_text(
                {
                    [dependency.name] = {
                        latest = dependency.version.latest,
                        current = dependency.version.latest,
                    },
                },
                -- In regular usage, we need to offset since it starts from 1
                dependency.position + 1,
                dependency.name
            )

            assert.are.equals("", dependency_metadata.icon)

            file.delete(file_name)
        end)

        it("shouldn't set the virtual text for up to date dependencies if hide_up_to_date is true", function()
            local dependency = {
                position = 3,
                name = "react",
                version = {
                    current = "16.0.0",
                    latest = "16.0.0",
                },
            }

            -- Simulate dependancies being parsed
            core.__dependencies = {
                [dependency.name] = {
                    version = dependency.version,
                },
            }

            local file_name = "package.json"

            file.create(
                file_name,
                string.format(
                    [[
                    {
                        "dependencies": {
                            "%s": "%s"
                        }
                    }
                    ]],
                    dependency.name,
                    dependency.version.current
                )
            )

            file.go(file_name)

            core.load_plugin()
            config.setup({ hide_up_to_date = true })

            local dependency_metadata = core.__set_virtual_text(
                {
                    [dependency.name] = {
                        latest = dependency.version.latest,
                        current = dependency.version.latest,
                    },
                },
                -- In regular usage, we need to offset since it starts from 1
                dependency.position + 1,
                dependency.name
            )

            assert.are.equals("", dependency_metadata.icon)
            assert.are.equals("", dependency_metadata.version)

            file.delete(file_name)
        end)

        it("should display the latest version when the current one is out of date", function()
            local dependency = {
                position = 3,
                name = "react",
                version = {
                    current = "16.0.0",
                    latest = "18.0.0",
                },
            }

            -- Simulate dependancies being parsed
            core.__dependencies = {
                [dependency.name] = {
                    version = dependency.version,
                },
            }

            local file_name = "package.json"

            file.create(
                file_name,
                string.format(
                    [[
                    {
                        "dependencies": {
                            "%s": "%s"
                        }
                    }
                    ]],
                    dependency.name,
                    dependency.version.current
                )
            )

            file.go(file_name)

            core.load_plugin()
            config.setup()

            local dependency_metadata = core.__set_virtual_text(
                {
                    [dependency.name] = {
                        latest = dependency.version.latest,
                        current = dependency.version.latest,
                    },
                },
                -- In regular usage, we need to offset since it starts from 1
                dependency.position + 1,
                dependency.name
            )

            assert.are.equals(config.options.icons.style.outdated, dependency_metadata.icon)
            assert.are.equals(dependency.version.latest, dependency_metadata.version)
            assert.are.equals(constants.HIGHLIGHT_GROUPS.outdated, dependency_metadata.group)

            file.delete(file_name)
        end)

        it("should display the existing version when the latest is the same", function()
            local dependency = {
                position = 3,
                name = "react",
                version = {
                    current = "16.0.0",
                    latest = "16.0.0",
                },
            }

            -- Simulate dependancies being parsed
            core.__dependencies = {
                [dependency.name] = {
                    version = dependency.version,
                },
            }

            local file_name = "package.json"

            file.create(
                file_name,
                string.format(
                    [[
                    {
                        "dependencies": {
                            "%s": "%s"
                        }
                    }
                    ]],
                    dependency.name,
                    dependency.version.current
                )
            )

            file.go(file_name)

            core.load_plugin()
            config.setup()

            local dependency_metadata = core.__set_virtual_text(
                {
                    [dependency.name] = {
                        latest = dependency.version.latest,
                        current = dependency.version.latest,
                    },
                },
                -- In regular usage, we need to offset since it starts from 1
                dependency.position + 1,
                dependency.name
            )

            assert.are.equals(config.options.icons.style.up_to_date, dependency_metadata.icon)
            assert.are.equals(dependency.version.current, dependency_metadata.version)
            assert.are.equals(constants.HIGHLIGHT_GROUPS.up_to_date, dependency_metadata.group)

            file.delete(file_name)
        end)
    end)

    describe("get_dependency_name_from_current_line", function()
        it("should get the name correctly", function()
            local dependency = {
                position = 3,
                name = "react",
                version = "16.0.0",
            }

            -- Simulate dependancies being parsed
            core.__dependencies = {
                [dependency.name] = {
                    version = {},
                },
            }

            local file_name = "package.json"

            file.create(
                file_name,
                string.format(
                    [[
                    {
                        "dependencies": {
                            "%s": "%s"
                        }
                    }
                    ]],
                    dependency.name,
                    dependency.version
                )
            )

            file.go(file_name)

            -- Go to line where dependency is
            vim.cmd(tostring(dependency.position))

            local dependency_name = core.get_dependency_name_from_current_line()

            assert.are.equals(dependency.name, dependency_name)

            file.delete(file_name)
        end)

        it("should return nil if no valid dependency is on the current line", function()
            local file_name = "package.json"

            file.create(file_name)
            file.go(file_name)

            spy.on(logger, "warn")

            local dependency_name = core.get_dependency_name_from_current_line()

            assert.is_nil(dependency_name)
            assert.spy(logger.warn).was_called(1)
            assert.spy(logger.warn).was_called_with("No valid package on current line")

            file.delete(file_name)
        end)
    end)

    describe("reload", function()
        it("should reload the buffer if it's package.json", function()
            local file_name = "package.json"

            file.create(
                file_name,
                [[
                {
                    "dependencies": {
                        "react": "16.0.0"
                    }
                }
                ]]
            )

            file.go(file_name)

            spy.on(core, "__reload_buffer")
            spy.on(core, "parse_buffer")

            core.reload()

            assert.spy(core.__reload_buffer).was_called(2)
            assert.spy(core.parse_buffer).was_called(1)

            file.delete(file_name)
        end)

        it("should reload the buffer and re-render virtual text if it's displayed and in package.json", function()
            state.displayed = true

            local file_name = "package.json"

            file.create(
                file_name,
                [[
                {
                    "dependencies": {
                        "react": "16.0.0"
                    }
                }
                ]]
            )

            file.go(file_name)

            config.setup()

            spy.on(core, "__reload_buffer")
            spy.on(core, "parse_buffer")
            spy.on(core, "clear_virtual_text")
            spy.on(core, "display_virtual_text")

            core.reload()

            assert.spy(core.__reload_buffer).was_called(2)
            assert.spy(core.parse_buffer).was_called(1)
            assert.spy(core.clear_virtual_text).was_called(1)
            assert.spy(core.display_virtual_text).was_called(1)

            file.delete(file_name)
        end)
    end)

    describe("display_virtual_text", function()
        it("should be called for each dependency in package.json", function()
            local file_name = "package.json"

            file.create(
                file_name,
                [[
                {
                    "dependencies": {
                        "react": "16.0.0",
                        "nextjs": "12.1.1"
                    }
                }
                ]]
            )

            file.go(file_name)

            config.setup()
            core.load_plugin()

            spy.on(core, "__set_virtual_text")

            core.reload()

            assert.is_true(state.displayed)
            assert.spy(core.__set_virtual_text).was_called(2)

            file.delete(file_name)
        end)
    end)
end)
