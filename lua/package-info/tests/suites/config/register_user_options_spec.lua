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
            colors = {
                up_to_date = "#ffffff",
                outdated = "#333333",
            },
            icons = {
                enable = false,
                style = {
                    up_to_date = "GG",
                    outdated = "NN",
                },
            },
            autostart = false,
            package_manager = constants.PACKAGE_MANAGERS.yarn,
            hide_up_to_date = true,
            hide_unstable_versions = true,
        }

        config.__register_user_options(options)

        assert.are.same(options, config.options)
    end)

    it("should keep default options if not changed by the user", function()
        local options = {
            colors = {
                up_to_date = "#ffffff",
                outdated = "#333333",
            },
        }

        config.__register_user_options(options)

        local merged_config = vim.tbl_deep_extend("keep", options, config.__DEFAULT_OPTIONS)

        assert.are.same(merged_config, config.options)
    end)
end)
