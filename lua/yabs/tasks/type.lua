local Group = require("yabs.tasks.group")
local utils = require("yabs.utils")

---@class Type
---@field name string
---@field groups table<string, Group>
---@field group_order string[]
local Type = {}

--- Instantiate Type
---@param name string
---@param runner string | table
---@param output string | table
---@return Type
function Type:new(name, runner, output)
  return setmetatable({
    name = name,
    runner = runner,
    output = output,
    groups = {},
    group_order = {}
  }, { __index = self })
end

--- Add group
---@param group Group
function Type:add_group(group)
  -- table.insert(self.groups, 1, group)
  self.groups[group.selector.name] = group
  table.insert(self.group_order, 1, group.selector.name)
end

function Type:add_tasks(tasks, selector)
  local existing_group = self.groups[selector.name]
  if existing_group then
    existing_group:add_tasks(tasks)
    local index = utils.tbl_get_index(self.group_order, selector.name)
    table.remove(self.group_order, index)
    table.insert(self.group_order, 1, selector.name)
  else
    self:add_group(Group:new(tasks, selector))
  end
end

--- Run task
---@param selector_name string | nil
---@param selection string | nil
function Type:run_task(selector_name, selection)
  local task
  if selector_name then
    local group = self.groups[selector_name]
    task = group.selector:make_selection(group.tasks)
  else
    for _, selector_name in ipairs(self.group_order) do
      local group = self.groups[selector_name]
      task = group.selector:make_selection(group.tasks)
      if task then break end
    end
  end
  assert(task, "yabs: no valid tasks for type " .. self.name)
  task:run()
end

return Type
