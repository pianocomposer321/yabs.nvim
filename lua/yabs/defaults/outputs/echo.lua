local Echo = require("yabs.core.output"):new()

function Echo:recieve(data)
  if self.opts.inspect then
    data = vim.inspect(data)
  end
  print(data)
end

return Echo
