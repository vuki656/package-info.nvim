-- FILE DESCRIPTION: Functionality related to upgrading dependency on current line

local UI = require("package-info.ui")
local utils = require("package-info.utils")

----------------------------------------------------------------------------
------------------------------ RETURN FUNCTION -----------------------------
----------------------------------------------------------------------------

return function()
    local package_name = utils.buffer.get_package_from_current_line()

    if package_name then
        -- TODO: possibly doesn't work
        UI.prompt.display({
            title = "Upgrade [" .. package_name .. "] Package",
            on_submit = function()
                vim.fn.jobstart("yarn upgrade " .. package_name .. "@latest", {
                    on_stdout = function()
                        vim.api.nvim_echo({ { package_name .. " upgraded successfully" } }, {}, {})
                        vim.cmd("e")
                        -- TODO: redraw versions or update that one extmark
                    end,
                })
            end,
        })
    else
        vim.api.nvim_echo({ { "No package under current line.", "WarningMsg" } }, {}, {})
    end
end
