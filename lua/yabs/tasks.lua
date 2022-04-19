local utils = require("yabs.utils")

local Task = require("yabs.tasks.task")
local Type = require("yabs.tasks.type")
local Group = require("yabs.tasks.group")
local Selector = require("yabs.tasks.selector")

local M = {}

local types = {}
local selectors = {}

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

local stateless_selector = function(selector)
  local new_selector = Selector:new()
  function new_selector:make_selection(tasks)
    return selector(tasks)
  end
  return new_selector
end

local stateful_selector = function(selector)
  local selector_type = type(selector)
  local name, opts
  if selector_type == "table" then
    name, opts = utils.extract_name_and_opts(selector)
  elseif selector_type == "string" then
    name = selector
  end
  return selectors[name]:new(name, opts)
end

local init_selector = function(selector)
  local selector_type = type(selector)
  if selector_type == "function" then
    return stateless_selector(selector)
  else
    return stateful_selector(selector)
  end
end

local init_task = function(task, runner, output)
  local command, opts = get_command_and_opts(task)
  local args
  command, args = utils.extract_command_and_args(command)
  opts = vim.tbl_extend("keep", opts or {}, {runner = runner, output = output} or {})
  runner = opts.runner
  output = opts.output
  opts.runner = nil
  opts.output = nil
  opts.selector = nil
  return Task:new(command, args, runner, output, opts)
end

local init_tasks = function(task_opts, runner, output)
  local tasks = {}
  for id, task in pairs(task_opts) do
    tasks[id] = init_task(task, runner, output)
  end
  return tasks
end

local init_group = function(task_opts, selector, runner, output)
  local tasks = init_tasks(task_opts, runner, output)
  return Group:new(tasks, init_selector(selector))
end

local init_type = function(runner, output)
  return Type:new(runner, output)
end

function M.add_type(name, runner, output)
  types[name] = init_type(runner, output)
end

function M.add_tasks(type, selector, tasks)
  if not types[type] then
    types[type] = init_type()
  end
  local existing_type = types[type]
  local group = init_group(tasks, selector, existing_type.runner, existing_type.output)
  types[type]:add_group(group)
end

function M.run_task(type_name, selector, selection)
  types[type_name]:run_task(selector, selection)
end

return M
