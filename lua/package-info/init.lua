local path_utils = require("package-info.utils.path")

local is_file_package_json = path_utils.is_current_file_package_json()

if is_file_package_json then
    print("hello")
else
    print("no")
end
