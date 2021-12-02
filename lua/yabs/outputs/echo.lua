local function echo(cmd)
  print(vim.fn.system(cmd))
end

local Output = require('yabs.output')
return Output:new(echo)
