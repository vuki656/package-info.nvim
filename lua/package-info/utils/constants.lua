local M = {}

M.HIGHLIGHT_GROUPS = {
    outdated = "PackageInfoOutdatedVersion",
    up_to_date = "PackageInfoUpToDateVersion",
    invalid = "PackageInfoInErrorVersion",
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

M.COMMANDS = {
    show = "PackageInfoShow",
    show_force = "PackageInfoShowForce",
    hide = "PackageInfoHide",
    delete = "PackageInfoDelete",
    update = "PackageInfoUpdate",
    install = "PackageInfoInstall",
    change_version = "PackageInfoChangeVersion",
}

M.AUTOGROUP = "PackageInfoAutogroup"
M.LOAD_EVENT = "PackageInfoStatusUpdate"

return M
