local function none(cmd)
  require('yabs.util').async_command(cmd)
end

local Output = require('yabs.output')
return Output:new(none)
