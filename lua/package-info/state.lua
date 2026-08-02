local M = {
    --- If true, the plugin has detected JS/TS project
    is_in_project = false,
    --- If true the current buffer is package json, with content and correct format
    is_loaded = false,
    --- If true the virtual text versions are displayed in package.json
    is_virtual_text_displayed = false,
    --- If true the project is using yarn 2<
    has_old_yarn = false,
}

M.dependencies = {
    -- Information loaded from pnpm_workspace
    -- catalog: {
    --   ["dependency_name"] = "0.0.0 (version)"
    -- }
    -- catalogs: {
    --   ["catalog_name"] = {
    --     ["dependency_name"] = "0.0.0 (version)"
    --   }
    -- }
    pnpm_workspace = {},
    -- Outdated dependencies from `npm outdated --json` as a list of
    -- [name]: {
    --     current: string - current dependency version
    --     latest: string - latest dependency version
    -- }
    outdated = {},
    -- Installed dependencies from package.json as a list of
    -- ["dependency_name"] = {
    --     current: string - current dependency version
    -- }
    installed = {},
    -- Detected dependencies with issues as a list of
    -- ["dependency_name"] = {
    --      diagnostic: string - feedback
    -- }
    invalid = {},
}

M.buffer = {
    id = nil,
    -- Full path of the package.json the plugin is operating on
    path = nil,
    -- String value of buffer from vim.api.nvim_buf_get_lines(state.buffer.id, 0, -1, false)
    lines = {},
    package_name = nil,
    --- Set the buffer id and path to the current buffer
    -- @return nil
    save = function()
        M.buffer.id = vim.api.nvim_get_current_buf()
        M.buffer.path = vim.api.nvim_buf_get_name(0)
    end,
}

M.last_run = {
    time = nil,
    --- Update M.last_run.time to now in milliseconds
    -- @return nil
    update = function()
        M.last_run.time = os.time()
    end,
    --- Invalidate the cache so the next run refetches the outdated dependencies
    -- Dependencies are hoisted, so a change in one package.json can invalidate
    -- the values stored for every other one
    -- @return nil
    reset = function()
        M.last_run.time = nil

        M.cache.reset()
    end,
    --- Determine if the next run should be skipped
    -- Skip if there was a run within the past hour
    -- @return boolean
    should_skip = function()
        local HOUR_IN_SECONDS = 3600

        if M.last_run.time == nil then
            return false
        end

        return os.time() < M.last_run.time + HOUR_IN_SECONDS
    end,
}

--- Values fetched for every package.json visited so far, so moving between
--- the packages of a monorepo doesn't refetch what is already known
M.cache = {
    entries = {},
    --- Store the fetched values of the currently loaded package.json
    -- @return nil
    save = function()
        if M.buffer.path == nil then
            return
        end

        M.cache.entries[M.buffer.path] = {
            outdated = M.dependencies.outdated,
            pnpm_workspace = M.dependencies.pnpm_workspace,
            time = M.last_run.time,
        }
    end,
    --- Load the values stored for the given package.json, clearing them if there are none
    -- @param path: string - full path of the package.json to load the values of
    -- @return nil
    restore = function(path)
        local entry = M.cache.entries[path] or {}

        M.dependencies.outdated = entry.outdated or {}
        M.dependencies.pnpm_workspace = entry.pnpm_workspace or {}
        M.last_run.time = entry.time
    end,
    --- Drop the values stored for every package.json
    -- @return nil
    reset = function()
        M.cache.entries = {}
    end,
}

M.namespace = {
    id = nil,
    --- Creates plugin specific namespace
    -- @return nil
    create = function()
        M.namespace.id = vim.api.nvim_create_namespace("package-info")
    end,
}

return M
