--- Register given highlight group
-- @param group: string - highlight group
-- @param color: string - color to use with the highlight group
-- @param type: string - color type to set
return function(group, color, type)
    vim.cmd("highlight " .. group .. " " .. type .. "=" .. color)
end
