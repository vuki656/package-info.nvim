local M = {}

M.register_highlight_group = function(group, color)
    vim.cmd("highlight " .. group .. " guifg=" .. color .. " gui=italic")
end

return M
