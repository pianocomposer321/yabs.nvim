local core = require("yabs.core")

local Task = require("yabs.tasks.task")
local Group = require("yabs.tasks.group")
local Selector = require("yabs.tasks.selector")

local M = {}

local groups = {}
local selectors = {}

M.get_group = function(group)
  if type(group) == "string" then
    return groups[group]
  end
  return group
end

M.get_selector = function(selector)
  if type(selector) == "string" then
    return selectors[selector]
  end
  return selector
end

M.register_selector = function(name, selector)
  selectors[name] = selector
end

local get_command_and_opts = function(task)
  local task_type = type(task)
  local command, opts
  if task_type == "string" then
    return task
  elseif task_type == "table" then
    command = task[1]
    opts = task
    opts[1] = nil
    return command, opts
  end
end

local stateful_selector = function(selector)
end

local init_selector = function(selector)
  local selector_type = type(selector)
  if selector_type == "string" then
    return selectors[selector]
  elseif selector_type == "function" then
    local new_selector = Selector:new()
    function new_selector:make_selection(tasks)
      return selector(tasks)
    end
    return new_selector
  end
end

local init_task = function(task, fallback_opts)
  local command, opts = get_command_and_opts(task)
  opts = vim.tbl_extend("keep", opts or {}, fallback_opts or {})
  local runner = core.get_runner(opts.runner)
  local output = core.get_output(opts.output)
  local selector = init_selector(opts.selector)
  opts.runner = nil
  opts.output = nil
  opts.selector = nil
  return Task:new(command, runner, output, selector, opts)
end

local init_group = function(task_opts, selector, fallback_opts)
  local tasks = {}
  for id, task in pairs(task_opts) do
    tasks[id] = init_task(task, fallback_opts)
  end
  return Group:new(tasks, selector)
end

function M.add_tasks(opts)
  local group = opts.group
  local tasks = opts.tasks
  local selector = opts.selector
  opts['group'] = nil
  opts['tasks'] = nil
  opts['selector'] = nil

  local fallback_opts = opts
  if not groups[group] then
    groups[group] = init_group(tasks, selector, fallback_opts)
  end
  P(groups)
end

function M.debug()
  require("yabs.tasks.test")
end

return M
