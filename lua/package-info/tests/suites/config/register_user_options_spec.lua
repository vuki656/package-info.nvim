local constants = require("package-info.utils.constants")
local config = require("package-info.config")

local reset = require("package-info.tests.utils.reset")

describe("Config register_user_options", function()
    before_each(function()
        reset.all()
    end)

    after_each(function()
        reset.all()
    end)

    it("should register user options", function()
        local options = {
            highlights = {
                up_to_date = {
                    fg = "#ffffff",
                    ctermfg = 15,
                },
                outdated = {
                    fg = "#333333",
                    ctermfg = 236,
                },
                invalid = {
                    fg = "#ff0000",
                    ctermfg = 196,
                },
            },
            icons = {
                enable = false,
                style = {
                    up_to_date = "GG",
                    outdated = "NN",
                    invalid = "",
                },
            },
            notifications = true,
            autostart = false,
            package_manager = constants.PACKAGE_MANAGERS.yarn,
            hide_up_to_date = true,
            hide_unstable_versions = true,
            timeout = 5000,
        }

        config.__register_user_options(options)

        assert.are.same(options, config.options)
    end)

    it("should keep default options if not changed by the user", function()
        local options = {
            highlights = {
                up_to_date = {
                    fg = "#ffffff",
                },
                outdated = {
                    fg = "#333333",
                },
            },
        }

        config.__register_user_options(options)

        local merged_config = vim.tbl_deep_extend("keep", options, config.__DEFAULT_OPTIONS)

        assert.are.same(merged_config, config.options)
    end)

    it("should migrate old colors to highlights option if highlights option is not provided", function()
        local options = {
            colors = {
                up_to_date = "#ffffff",
                outdated = "#333333",
                invalid = 123,
            },
        }

        local expected_options = vim.deepcopy(config.__DEFAULT_OPTIONS)
        expected_options.highlights = {
            up_to_date = {
                fg = "#ffffff",
                ctermfg = 237,
            },
            outdated = {
                fg = "#333333",
                ctermfg = 173,
            },
            invalid = {
                fg = "#ee4b2b",
                ctermfg = 123,
            },
        }

        config.__register_user_options(options)

        assert.are.same(expected_options, config.options)
    end)

    it("should not migrate old colors to highlights option if highlights option is provided", function()
        local options = {
            colors = {
                up_to_date = "#ffffff",
                outdated = "#333333",
                invalid = "#ff0000",
            },
            highlights = {
                up_to_date = {
                    fg = "#0D1117",
                    ctermfg = 236,
                },
            },
        }

        local expected_options = vim.deepcopy(config.__DEFAULT_OPTIONS)
        expected_options.highlights = {
            up_to_date = {
                fg = "#0D1117",
                ctermfg = 236,
            },
            outdated = {
                fg = "#d19a66",
                ctermfg = 173,
            },
            invalid = {
                fg = "#ee4b2b",
                ctermfg = 196,
            },
        }

        config.__register_user_options(options)

        assert.are.same(expected_options, config.options)
    end)
end)
