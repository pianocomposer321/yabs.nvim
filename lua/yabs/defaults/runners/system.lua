local Runner = require("yabs.core.runner")

local System = Runner:new()

function System:run(output)
  local command = self.command
  local args = self.args
  if args then
    command = vim.tbl_flatten {command, args}
  end
  local data = vim.fn.system(command)
  output:recieve(data)
end

return System
