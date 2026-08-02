local M = {}

function M.root(path)
    local f = debug.getinfo(1, "S").source:sub(2)
    return vim.fn.fnamemodify(f, ":p:h:h:h:h") .. "/" .. (path or "")
end

function M.load(plugin)
    local name = plugin:match(".*/(.*)")
    local package_root = M.root(".tests/site/pack/deps/start/")

    if not vim.uv.fs_stat(package_root .. name) then
        print("Installing " .. plugin)
        vim.fn.mkdir(package_root, "p")
        vim.fn.system({
            "git",
            "clone",
            "--depth=1",
            "https://github.com/" .. plugin .. ".git",
            package_root .. name,
        })
    end
end

function M.setup()
    vim.o.runtimepath = vim.env.VIMRUNTIME
    vim.opt.runtimepath:append(M.root())
    vim.opt.packpath = { M.root(".tests/site") }

    M.load("echasnovski/mini.test")
    M.load("MunifTanjim/nui.nvim")

    vim.env.XDG_CONFIG_HOME = M.root(".tests/config")
    vim.env.XDG_DATA_HOME = M.root(".tests/data")
    vim.env.XDG_STATE_HOME = M.root(".tests/state")
    vim.env.XDG_CACHE_HOME = M.root(".tests/cache")

    local path = vim.env.PI_TEST_PATH or "lua/package-info/tests/suites"

    require("mini.test").setup({
        collect = {
            find_files = function()
                if vim.fn.isdirectory(path) == 0 then
                    return { path }
                end

                local files = vim.fn.globpath(path, "**/*_spec.lua", true, true)
                table.sort(files)

                return files
            end,
        },
    })
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.swapfile = false

M.setup()
