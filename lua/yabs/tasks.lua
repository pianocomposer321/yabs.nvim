local Task = require("yabs.tasks.task")

local tasks = {}

local M = {}

function M.get_active_tasks()
  return vim.tbl_filter(function(task)
    return task:get_active()
  end, tasks)
end

function M.add_tasks(a_tasks)
  for _, task_args in ipairs(a_tasks) do
    table.insert(tasks, 1, Task:new(task_args))
  end
end

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
