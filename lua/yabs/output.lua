local Output = {}

function Output:init(opts, command, args)
  self.opts = opts
  self.command = command
end

function Output:new(opts, command, args)
  local new_output = setmetatable({}, { __index = self })
  new_output:init(opts, command)
  return new_output
end

function Output:recieve(data)
end

return Output
