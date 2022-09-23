local json_parser = require("package-info.libs.json_parser")
local logger = require("package-info.utils.logger")
local safe_call = require("package-info.utils.safe-call")

--- Runs an async job
-- @param props.command - string command to run
-- @param props.on_success - function to invoke with the results
-- @param props.on_error - function to invoke if the command fails
-- @param props.ignore_error?: boolean - ignore non-zero exit codes (npm outdated throws 1 when getting the list)
-- @param props.on_start?: function - callback to invoke before the job starts
-- @param props.json?: boolean - if output should be parsed as json
-- @return nil
return function(props)
    local value = ""

    safe_call(props.on_start)

    local function on_error()
        logger.error("Error running " .. props.command .. ". Try running manually.")

        if props.on_error ~= nil then
            props.on_error()
        end
    end

    -- If a package.json file is open, use the directory of the file
    -- as working directory for the job
    local cwd = vim.fn.getcwd()
    if string.sub(vim.fn.expand("%:p"), -12) == "package.json" then
        cwd = string.sub(vim.fn.expand("%:p"), 1, -13)
    end

    vim.fn.jobstart(props.command, {
        cwd = cwd,
        on_exit = function(_, exit_code)
            if exit_code ~= 0 and not props.ignore_error then
                on_error()

                return
            end

            if props.json then
                local ok, json_value = pcall(json_parser.decode, value)

                if ok then
                    props.on_success(json_value)

                    return
                end

                on_error()
            else
                props.on_success(value)
            end
        end,
        on_stdout = function(_, stdout)
            value = value .. table.concat(stdout)
        end,
    })
end
