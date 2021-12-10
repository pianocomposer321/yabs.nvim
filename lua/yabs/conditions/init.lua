local Path = require('plenary.path')
local M = {}

function M.file_exists(file)
  return function()
    return Path:new(file):exists()
  end
end

return M
