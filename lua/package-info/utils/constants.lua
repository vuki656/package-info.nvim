-- FILE DESCRIPTION: Constants reused within the plugin

local M = {}

M.HIGHLIGHT_GROUPS = {
    outdated = "PackageInfoOutdatedVersion",
    up_to_date = "PackageInfoUpToDateVersion",
}

M.PACKAGE_MANAGERS = {
    yarn = "yarn",
    npm = "npm",
    pnpm = "pnpm",
}

M.DEPENDENCY_TYPE = {
    production = "prod",
    development = "dev",
}

return M
