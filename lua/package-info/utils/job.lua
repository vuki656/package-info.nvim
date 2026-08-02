local logger = require("package-info.utils.logger")
local safe_call = require("package-info.utils.safe-call")
local find_upwards = require("package-info.utils.find-upwards")

--- Returns the directory the command should run in
-- It is the directory of the open package.json, the directory of the closest
-- package.json above the open file, or the current working directory
-- @return string
local get_cwd = function()
    local file_path = vim.fn.expand("%:p")

    if file_path == "" then
        return vim.fn.getcwd()
    end

    local file_directory = vim.fn.fnamemodify(file_path, ":h")

    if string.sub(file_path, -12) == "package.json" and vim.fn.isdirectory(file_directory) == 1 then
        return file_directory
    end

    local package_json_directory = find_upwards(file_directory, function(directory)
        return vim.fn.filereadable(directory .. "/package.json") == 1
    end)

    return package_json_directory or vim.fn.getcwd()
end

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

        safe_call(props.on_error)
    end

    vim.fn.jobstart(props.command, {
        cwd = get_cwd(),
        on_exit = function(_, exit_code)
            if exit_code ~= 0 and not props.ignore_error then
                on_error()

                return
            end

            if props.json then
                local ok, json_value = pcall(vim.json.decode, value)

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
