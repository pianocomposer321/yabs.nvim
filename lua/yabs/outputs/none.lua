local function none(cmd)
  require('yabs.utils').async_command(cmd)
end

local Output = require('yabs.output')
return Output:new(none)
