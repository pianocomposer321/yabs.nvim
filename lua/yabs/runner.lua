local Runner = {}

function Runner:init(opts, command, args)
  self.opts = opts
  self.command = command
  self.args = args
end

function Runner:new(opts, command, args)
  local new_runner = setmetatable({}, { __index = self })
  new_runner:init(opts, command, args)
  return new_runner
end

function Runner:run(output)
end

return Runner
