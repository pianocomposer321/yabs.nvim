local Group = {}

function Group:new(tasks, selector)
  return setmetatable({
    tasks = tasks,
    selector = selector
  }, { __index = self })
end

return Group
