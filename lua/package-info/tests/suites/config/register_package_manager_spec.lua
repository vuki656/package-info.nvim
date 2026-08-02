local expect = MiniTest.expect

local constants = require("package-info.utils.constants")
local config = require("package-info.config")
local state = require("package-info.state")

local file = require("package-info.tests.utils.file")
local reset = require("package-info.tests.utils.reset")

local T = MiniTest.new_set({
    hooks = {
        pre_case = reset.all,
        post_case = reset.all,
    },
})

T["should detect npm package manager"] = function()
    local package_json = file.create_package_json({ go = true })
    local lock_file_path = vim.fn.fnamemodify(package_json.path, ":h") .. "/package-lock.json"
    local created_file = file.create({ name = lock_file_path })

    config.__register_package_manager()

    file.delete(created_file.path)
    file.delete(package_json.path)

    expect.equality(config.options.package_manager, constants.PACKAGE_MANAGERS.npm)
end

T["should detect yarn package manager"] = function()
    local package_json = file.create_package_json({ go = true })
    local lock_file_path = vim.fn.fnamemodify(package_json.path, ":h") .. "/yarn.lock"
    local created_file = file.create({ name = lock_file_path })

    config.__register_package_manager()

    file.delete(created_file.path)
    file.delete(package_json.path)

    expect.equality(config.options.package_manager, constants.PACKAGE_MANAGERS.yarn)
end

T["should detect pnpm package manager"] = function()
    local package_json = file.create_package_json({ go = true })
    local lock_file_path = vim.fn.fnamemodify(package_json.path, ":h") .. "/pnpm-lock.yaml"
    local created_file = file.create({ name = lock_file_path })

    config.__register_package_manager()

    file.delete(created_file.path)
    file.delete(package_json.path)

    expect.equality(config.options.package_manager, constants.PACKAGE_MANAGERS.pnpm)
end

T["should detect bun package manager"] = function()
    local package_json = file.create_package_json({ go = true })
    local lock_file_path = vim.fn.fnamemodify(package_json.path, ":h") .. "/bun.lock"
    local created_file = file.create({ name = lock_file_path })

    config.__register_package_manager()

    file.delete(created_file.path)
    file.delete(package_json.path)

    expect.equality(config.options.package_manager, constants.PACKAGE_MANAGERS.bun)
end

T["should prioritize yarn when both yarn.lock and bun.lock exist"] = function()
    local package_json = file.create_package_json({ go = true })
    local dir = vim.fn.fnamemodify(package_json.path, ":h")

    local yarn_lock = file.create({ name = dir .. "/yarn.lock" })
    local bun_lock = file.create({ name = dir .. "/bun.lock" })

    config.__register_package_manager()

    file.delete(yarn_lock.path)
    file.delete(bun_lock.path)
    file.delete(package_json.path)

    expect.equality(config.options.package_manager, constants.PACKAGE_MANAGERS.yarn)
end

T["should prioritize npm when both package-lock.json and bun.lock exist"] = function()
    local package_json = file.create_package_json({ go = true })
    local dir = vim.fn.fnamemodify(package_json.path, ":h")

    local npm_lock = file.create({ name = dir .. "/package-lock.json" })
    local bun_lock = file.create({ name = dir .. "/bun.lock" })

    config.__register_package_manager()

    file.delete(npm_lock.path)
    file.delete(bun_lock.path)
    file.delete(package_json.path)

    expect.equality(config.options.package_manager, constants.PACKAGE_MANAGERS.npm)
end

T["should prioritize bun when both bun.lock and pnpm-lock.yaml exist"] = function()
    local package_json = file.create_package_json({ go = true })
    local dir = vim.fn.fnamemodify(package_json.path, ":h")

    local bun_lock = file.create({ name = dir .. "/bun.lock" })
    local pnpm_lock = file.create({ name = dir .. "/pnpm-lock.yaml" })

    config.__register_package_manager()

    file.delete(bun_lock.path)
    file.delete(pnpm_lock.path)
    file.delete(package_json.path)

    expect.equality(config.options.package_manager, constants.PACKAGE_MANAGERS.bun)
end

T["should detect a lock file above the package.json directory"] = function()
    local root = vim.fn.fnamemodify(file.generate_file(), ":h")
    local nested = root .. "/packages/website"

    vim.fn.mkdir(nested, "p")

    local lock_file = file.create({ name = root .. "/pnpm-lock.yaml" })
    local package_json = file.create({ name = nested .. "/package.json", content = "{}", go = true })

    config.__register_package_manager()

    local is_in_project = state.is_in_project

    file.delete(package_json.path)
    file.delete(lock_file.path)

    expect.equality(config.options.package_manager, constants.PACKAGE_MANAGERS.pnpm)
    expect.equality(is_in_project, true)
end

T["should not register a package manager when the buffer is not a file on disk"] = function()
    local buffer = vim.api.nvim_create_buf(true, false)

    vim.api.nvim_buf_set_name(buffer, "diffview:///home/user/project/.git/abc123/package.json")
    vim.api.nvim_set_current_buf(buffer)

    state.is_in_project = false

    config.__register_package_manager()

    local is_in_project = state.is_in_project

    vim.cmd("edit void")
    vim.api.nvim_buf_delete(buffer, { force = true })

    expect.equality(is_in_project, false)
end

return T
