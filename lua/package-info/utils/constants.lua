local M = {}

M.DEFAULT_OPTIONS = {
    colors = {
        up_to_date = "#89ca78",
        outdated = "#ef596f",
    },
    icons = {
        enable = true,
        style = {
            up_to_date = "|  ",
            outdated = "|  ",
        },
    },
}

M.HIGHLIGHT_GROUPS = {
    outdated = "PackageInfoOutdatedVersion",
    up_to_date = "PackageInfoUpToDateVersion",
}

return M
