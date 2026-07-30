local state = require("package-info.state")
local reload = require("package-info.helpers.reload")

--- Invalidates the cached outdated dependencies after a dependency was changed
-- and refetches them if the virtual text is currently displayed
-- @return nil
return function()
    state.last_run.reset()

    if not state.is_virtual_text_displayed then
        reload()

        return
    end

    require("package-info.actions.show").run({ force = true })
end
