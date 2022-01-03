local utils = require("package-info.utils")

local dependency_type_select = require("package-info.ui.dependency-type-select")
local dependency_name_input = require("package-info.ui.dependency-name-input")

local core = require("package-info.modules.core")

function display_dependency_name_input(selected_dependency_type)
    dependency_name_input.new({
        on_submit = function(dependency_name)
            utils.loading.start("|  Installing " .. dependency_name .. " package")

            utils.job({
                command = utils.get_command.install(selected_dependency_type, dependency_name),
                on_success = function()
                    core.__reload()

                    utils.loading.stop()
                end,
                on_error = function()
                    utils.loading.stop()
                end,
            })
        end,
    })

    dependency_name_input.open()
end

return function()
    dependency_type_select.new({
        on_submit = function(selected_dependency_type)
            display_dependency_name_input(selected_dependency_type)
        end,
    })

    dependency_type_select.open()
end
