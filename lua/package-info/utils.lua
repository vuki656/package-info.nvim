local json_parser = require("package-info.libs.json_parser")

local logger = require("package-info.logger")

M = {}

--- Checks if given string contains "error"
-- For now probably acceptable, but should be more precise
-- @param value - string to check
M.has_errors = function(value)
    local string_value = value

    if type(value) ~= "string" then
        string_value = table.concat(value)
    end

    return string.find(string_value, "error") ~= nil
end

--- Manages loading animation state
M.loading = {
    animation = {
        "⠋",
        "⠙",
        "⠹",
        "⠸",
        "⠼",
        "⠴",
        "⠦",
        "⠧",
        "⠇",
        "⠏",
    },
    index = 1,
    log = "",
    spinner = "",
    is_running = false,
    fetch = function()
        return M.loading.spinner .. " " .. M.loading.log
    end,
    start = function(message)
        M.loading.log = message
        M.loading.is_running = true
        M.loading.update()
    end,
    stop = function()
        M.loading.is_running = false
        M.loading.log = ""
        M.loading.spinner = ""
    end,
    update = function()
        if M.loading.is_running then
            M.loading.spinner = M.loading.animation[M.loading.index]

            M.loading.index = M.loading.index + 1

            if M.loading.index == 10 then
                M.loading.index = 1
            end

            vim.fn.timer_start(80, function()
                M.loading.update()
            end)
        end
    end,
}

--- Runs an async job
-- @param options.command - string command to run
-- @param options.json - boolean if output should be parsed as json
-- @param options.callback - function to invoke with the results
M.job = function(options)
    local value = ""

    vim.fn.jobstart(options.command, {
        on_stdout = function(_, stdout)
            value = value .. table.concat(stdout)

            if table.concat(stdout) == "" then
                local has_error = M.has_errors(stdout)

                if has_error then
                    logger.error("Error running " .. options.command .. ". Try running manually.")

                    options.on_error(stdout)

                    return
                end

                if options.json then
                    local json_value = json_parser.decode(value)

                    options.on_success(json_value)

                    return
                end

                options.on_success(value)
            end
        end,
    })
end

return M
