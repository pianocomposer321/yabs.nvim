local M = {}

function M.file_exists(file)
    return function()
        return require("yabs.util").file_exists(file)
    end
end

return M
