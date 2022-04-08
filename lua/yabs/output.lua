local Output = {}

function Output:init(opts)
  self.opts = opts
end

function Output:new(opts)
  local new_output = setmetatable({}, { __index = self })
  new_output:init(opts)
  return new_output
end

function Output:recieve(data)
end

return Output
