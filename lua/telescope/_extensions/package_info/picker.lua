local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local telescope_package_info_config = require("telescope._extensions.package_info.config")

local M = {}

function M.picker()
    local opts = telescope_package_info_config.opts or {}

    pickers
        .new(opts, {
            prompt_title = "Package info",
            finder = finders.new_table({
                results = {
                    {
                        "Show latest versions",
                        {
                            command = "show",
                            args = {},
                        },
                    },
                    {
                        "Show latest versions (force)",
                        {
                            command = "show",
                            args = { force = true },
                        },
                    },
                    {
                        "Hide latest versions",
                        {
                            command = "hide",
                            args = {},
                        },
                    },
                    {
                        "Delete package",
                        {
                            command = "delete",
                            args = {},
                        },
                    },
                    {
                        "Change package version",
                        {
                            command = "change_version",
                            args = {},
                        },
                    },
                    {
                        "Install package",
                        {
                            command = "install",
                            args = {},
                        },
                    },
                },
                entry_maker = function(entry)
                    return {
                        value = entry[2],
                        display = entry[1],
                        ordinal = entry[1],
                    }
                end,
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    local value = selection.value
                    require("package-info")[value.command](value.args)
                end)
                return true
            end,
        })
        :find()
end

return M
