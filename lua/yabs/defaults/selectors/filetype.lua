local Filetype = require("yabs.tasks.selector"):new()

function Filetype:select()
  return vim.bo.filetype
end

return Filetype
