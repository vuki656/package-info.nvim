local state = require("package-info.state")
local logger = require("package-info.utils.logger")
local get_dependency_name_from_line = require("package-info.helpers.get_dependency_name_from_line")

--- Gets dependency name from current line
-- @return string?
return function()
    local current_line = vim.fn.getline(".")

    local dependency_name = get_dependency_name_from_line(current_line)

    if state.dependencies.installed[dependency_name] then
        return dependency_name
    else
        logger.warn("No valid dependency on current line")

        return nil
    end
end
