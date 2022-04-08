local Runner = {}

function Runner:init(opts)
  self.opts = opts
end

function Runner:new(opts)
  local new_runner = setmetatable({}, { __index = self })
  new_runner:init(opts)
  return new_runner
end

function Runner:run(command, args, output)
end

return Runner
