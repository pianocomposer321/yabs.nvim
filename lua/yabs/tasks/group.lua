---@class Group
---@field tasks Task[]
---@field selector Selector
local Group = {}

--- Instantiate Group
---@param tasks Task[]
---@param selector Selector
---@return Group
function Group:new(tasks, selector)
  return setmetatable({
    tasks = tasks,
    selector = selector
  }, { __index = self })
end

function Group:add_tasks(tasks)
  self.tasks = vim.tbl_extend("force", self.tasks, tasks)
end

return Group
