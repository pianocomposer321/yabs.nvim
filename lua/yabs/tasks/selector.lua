local Selector = {}

function Selector:new(name, opts)
  return setmetatable({ name = name, opts = opts or {} }, { __index = self })
end

function Selector:select() end

function Selector:make_selection(tasks)
  return tasks[self:select()]
end

return Selector
