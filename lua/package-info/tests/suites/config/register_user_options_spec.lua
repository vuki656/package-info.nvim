local expect = MiniTest.expect

local constants = require("package-info.utils.constants")
local config = require("package-info.config")

local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should register user options"] = function()
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

    expect.equality(config.options, options)
end

T["should keep default options if not changed by the user"] = function()
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

    expect.equality(config.options, merged_config)
end

T["should migrate old colors to highlights option if highlights option is not provided"] = function()
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

    expect.equality(config.options, expected_options)
end

T["should not migrate old colors to highlights option if highlights option is provided"] = function()
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

    expect.equality(config.options, expected_options)
end

return T
