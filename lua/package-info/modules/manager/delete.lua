-- FILE DESCRIPTION: Functionality related to deleting dependency on current line

local UI = require("package-info.ui")
local utils = require("package-info.utils")

----------------------------------------------------------------------------
------------------------------ RETURN FUNCTION -----------------------------
----------------------------------------------------------------------------

return function()
    local package_name = utils.buffer.get_package_from_current_line()

    if package_name then
        UI.prompt.display({
            title = "Delete [" .. package_name .. "] Package",
            on_submit = function()
                vim.fn.jobstart("yarn remove " .. package_name, {
                    on_stdout = function()
                        vim.api.nvim_echo({ { package_name .. " deleted successfully" } }, {}, {})
                        vim.cmd("e")
                        -- TODO: redraw versions or delete extmark
                        -- nvim_buf_del_extmark({buffer}, {ns_id}, {id})         *nvim_buf_del_extmark()*
                    end,
                })
            end,
        })
    else
        vim.api.nvim_echo({ { "No package under current line.", "WarningMsg" } }, {}, {})
    end
end
