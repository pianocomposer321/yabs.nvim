local utils = require('yabs.utils')
local Job = require('plenary.job')

local function none(cmd)
  local splitted_cmd = utils.split_cmd(cmd)
  local job = Job:new({
    command = table.remove(splitted_cmd, 1),
    args = splitted_cmd,
  })
  job:start()
end

local Output = require('yabs.output')
return Output:new(none)
