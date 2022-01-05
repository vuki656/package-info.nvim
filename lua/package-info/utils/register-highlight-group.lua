--- Register given highlight group
-- @param group: string - highlight group
-- @param color: string - color to use with the highlight group
return function(group, color)
    local type = "guifg"

    --- 256 color support
    if not vim.o.termguicolors then
        type = "ctermfg"
    end

    vim.cmd("highlight " .. group .. " " .. type .. "=" .. color)
end
