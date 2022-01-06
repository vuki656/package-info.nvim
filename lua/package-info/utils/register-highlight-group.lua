--- Register given highlight group
-- @param group: string - highlight group to register
-- @param color: string - color to use with the highlight group
return function(highlight_group, color)
    local type = "guifg"

    --- 256 color support
    if not vim.o.termguicolors then
        type = "ctermfg"
    end

    vim.cmd("highlight " .. highlight_group .. " " .. type .. "=" .. color)
end
