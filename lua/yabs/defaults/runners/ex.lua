local Runner = require("yabs.core.runner")

local Ex = Runner:new()

function Ex:run()
  local command = self.command
  local args = self.args
  if args then
    command = table.concat(vim.tbl_flatten {command, args}, " ")
  end
  vim.api.nvim_command(command)
end

return Ex
