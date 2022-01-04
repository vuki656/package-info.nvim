local utils = require("package-info.utils")
local core = require("package-info.core")
local prompt = require("package-info.ui.generic.prompt")
local job = require("package-info.utils.job")

local loading = require("package-info.ui.generic.loading-status")

return function()
    local dependency_name = core.__get_dependency_name_from_current_line()

    if dependency_name == nil then
        return
    end

    local id = loading.new("| ﯁ Updating " .. dependency_name .. " package")

    prompt.new({
        title = " Update [" .. dependency_name .. "] Package ",
        on_submit = function()
            job({
                json = false,
                command = utils.get_command.update(dependency_name),
                on_start = function()
                    loading.start(id)
                end,
                on_success = function()
                    core.__reload()

                    loading.start(id)
                end,
                on_error = function()
                    loading.start(id)
                end,
            })
        end,
        on_cancel = function()
            utils.loading.stop()
        end,
        on_error = function()
            core.__reload()

            utils.loading.stop()
        end,
    })

    prompt.open({
        on_error = function()
            utils.loading.stop()
        end,
    })
end
