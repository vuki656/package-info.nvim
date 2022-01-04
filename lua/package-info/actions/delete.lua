local prompt = require("package-info.ui.generic.prompt")
local utils = require("package-info.utils")
local job = require("package-info.utils.job")
local loading = require("package-info.ui.generic.loading-status")

local core = require("package-info.core")

return function()
    local dependency_name = core.__get_dependency_name_from_current_line()

    if dependency_name == nil then
        return
    end

    local loading_id = loading.new("|  Deleting " .. dependency_name .. " package")

    prompt.new({
        title = " Delete [" .. dependency_name .. "] Package ",
        on_submit = function()
            loading.start(loading_id)

            job({
                json = false,
                command = utils.get_command.delete(dependency_name),
                on_success = function()
                    core.__reload()

                    loading.stop(loading_id)
                end,
                on_error = function()
                    loading.stop(loading_id)
                end,
            })
        end,
        on_cancel = function()
            loading.stop(loading_id)
        end,
    })

    prompt.open({
        on_error = function()
            loading.stop(loading_id)
        end,
    })
end
