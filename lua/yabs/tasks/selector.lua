local Selector = {}
Selector.__instances = {}

function Selector:new(name)
  return setmetatable({}, { __index = Selector })
end

return Selector
