local function consolation(cmd)
  require('consolation').send_command({ cmd = cmd })
end

local Output = require('yabs.output')
return Output:new(consolation)
