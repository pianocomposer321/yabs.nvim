---@class Selector
---@field name string
---@field opts table<string, any>
local Selector = {}

--- Instantiate Selector
---@param name string
---@param opts table<string, any>
---@return Selector
function Selector:new(name, opts)
  return setmetatable({ name = name, opts = opts or {} }, { __index = self })
end

--- Select task. Meant to be overridden.
---@return string
function Selector:select() end

--- Make selection
---@param tasks Task[]
---@return Task
function Selector:make_selection(tasks)
  return tasks[self:select()]
end

return Selector
