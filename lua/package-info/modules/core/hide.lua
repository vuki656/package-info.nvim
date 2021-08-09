-- FILE DESCRIPTION: Functionality for clearing package info virtual text

local globals = require("package-info.globals")

----------------------------------------------------------------------------
------------------------------ RETURN FUNCTION -----------------------------
----------------------------------------------------------------------------

-- Contains functionality needed in order to clear package-info virtual text
return function()
    vim.api.nvim_buf_clear_namespace(0, globals.namespace.id, 0, -1)
end
