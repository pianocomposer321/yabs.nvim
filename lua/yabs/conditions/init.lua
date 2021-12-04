local M = {}

function M.file_exists(file)
  return function()
    return require('yabs.utils').file_exists(file)
  end
end

return M
