local logger = require("package-info.logger")

if vim.json then
    json_parser = vim.json
else
    json_parser = require("package-info.libs.json_parser")
end

-- TODO: cleanup
--- Runs an async job
-- @param options.command - string command to run
-- @param options.json - boolean if output should be parsed as json
-- @param options.on_success - function to invoke with the results
-- @param options.on_error - function to invoke if the command fails
-- @param options.ignore_error - ignore non-zero exit codes
return function(options)
    local value = ""

    vim.fn.jobstart(options.command, {
        on_exit = function(_, exit_code)
            if exit_code ~= 0 and not options.ignore_error then
                logger.error("Error running " .. options.command .. ". Try running manually.")

                if options.on_error ~= nil then
                    options.on_error()
                end

                return
            end

            if options.json then
                local ok, json_value = pcall(json_parser.decode, value)

                if ok then
                    options.on_success(json_value)
                else
                    logger.error("Error running " .. options.command .. ". Try running manually.")

                    if options.on_error ~= nil then
                        options.on_error()
                    end
                end
            else
                options.on_success(value)
            end
        end,
        on_stdout = function(_, stdout)
            value = value .. table.concat(stdout)
        end,
    })
end
