local json_parser

if vim.json then
    json_parser = vim.json
else
    json_parser = require("package-info.libs.json_parser")
end

local logger = require("package-info.utils.logger")
local safe_call = require("package-info.utils.safe-call")

--- Runs an async job
-- @param props.command - string command to run
-- @param props.on_success - function to invoke with the results
-- @param props.on_error - function to invoke if the command fails
-- @param props.ignore_error?: boolean - ignore non-zero exit codes (npm outdated throws 1 when getting the list for example)
-- @param props.on_start?: function - callback to invoke before the job starts
-- @param props.json?: boolean - if output should be parsed as json
return function(props)
    local value = ""

    safe_call(props.on_start)

    function on_error()
        logger.error("Error running " .. props.command .. ". Try running manually.")

        if props.on_error ~= nil then
            props.on_error()
        end
    end

    vim.fn.jobstart(props.command, {
        on_exit = function(_, exit_code)
            if exit_code ~= 0 and not props.ignore_error then
                on_error()

                return
            end

            if props.json then
                local ok, json_value = pcall(json_parser.decode, value)

                if ok then
                    props.on_success(json_value)
                else
                    on_error()

                    return
                end

                props.on_success(value)
            end
        end,
        on_stdout = function(_, stdout)
            value = value .. table.concat(stdout)
        end,
    })
end
