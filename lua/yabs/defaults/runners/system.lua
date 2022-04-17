local Runner = require("yabs.core.runner")

local System = Runner:new()

function System:init()
  self.status = self.__statuses.IDLE
end

function System:run(output)
  self:set_status(self.__statuses.RUNNING)
  local command = self.command
  local args = self.args
  if args then
    command = vim.tbl_flatten {command, args}
  end
  local data = vim.fn.system(command)
  output:recieve(data)
  self:set_status(self.__statuses.EXITED)
end

return System
