local commands = require("package-info.commands")
local core = require("package-info.core")
local job = require("package-info.utils.job")

local dependency_type_select = require("package-info.ui.dependency-type-select")
local dependency_name_input = require("package-info.ui.dependency-name-input")
local loading = require("package-info.ui.generic.loading-status")

function display_dependency_name_input(selected_dependency_type)
    dependency_name_input.new({
        on_submit = function(dependency_name)
            local id = loading.new("|  Installing " .. dependency_name .. " package")

            job({
                command = commands.get_install(selected_dependency_type, dependency_name),
                on_start = function()
                    loading.start(id)
                end,
                on_success = function()
                    core.reload()

                    loading.stop(id)
                end,
                on_error = function()
                    loading.stop(id)
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
