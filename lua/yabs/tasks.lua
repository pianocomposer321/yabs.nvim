local Task = require("yabs.tasks.task")

local tasks = {}

local M = {}

--- Get active tasks
---@return Task[]
function M.get_active_tasks()
  return vim.tbl_filter(function(task)
    return task:get_active()
  end, tasks)
end

--- Add tasks
---@param a_tasks table
function M.add_tasks(a_tasks)
  for _, task_args in ipairs(a_tasks) do
    table.insert(tasks, 1, Task:new(task_args))
  end
end

--- Run task
---@param args table
function M.run_task(args)
  local filtered_tasks = vim.tbl_filter(function(task)
    for prop, value in pairs(args) do
      if task[prop] ~= value then return false end
    end
    return true
  end, M.get_active_tasks())
  filtered_tasks[1]:run()
end

return M
