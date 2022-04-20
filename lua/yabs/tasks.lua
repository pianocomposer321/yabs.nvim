local utils = require("yabs.utils")
local core  = require("yabs.core")

local Task = require("yabs.tasks.task")
local Type = require("yabs.tasks.type")
local Group = require("yabs.tasks.group")
local Selector = require("yabs.tasks.selector")

local M = {}

local types = {}
local selectors = {}

--- Register selector
---@param name string
---@param selector Selector
M.register_selector = function(name, selector)
  selectors[name] = selector
end

M.get_selector = function(name)
  return assert(selectors[name], "yabs: no selector named " .. name)
end

--- Check if selector with `name` exists
---@param name string
---@return boolean
M.has_selector = function(name)
  return selectors[name] ~= nil
end

--- Get command and opts
---@param task string | table
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

--- Stateless selector
---@see stateless_runner
---@param selector fun(tasks: Task[])
---@return Selector
local stateless_selector = function(selector)
  local new_selector = Selector:new()
  function new_selector:make_selection(tasks)
    return selector(tasks)
  end
  return new_selector
end

--- Statefull selector
---@see stateful_runner
---@param selector table | string
---@return Selector
local stateful_selector = function(selector)
  local selector_type = type(selector)
  local name, opts
  if selector_type == "table" then
    name, opts = utils.extract_name_and_opts(selector)
  elseif selector_type == "string" then
    name = selector
  end
  assert(M.has_selector(name), "yabs: no selector named " .. name)
  return selectors[name]:new(name, opts)
end

--- Initialize selector
---@param selector function | string
---@return Selector
local init_selector = function(selector)
  local selector_type = type(selector)
  if selector_type == "function" then
    return stateless_selector(selector)
  else
    return stateful_selector(selector)
  end
end

--- Initialize task
---@param task_name string | table
---@param runner string
---@param output string
---@return Task
local init_task = function(task_name, runner, output)
  local command, opts = get_command_and_opts(task_name)
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

--- Initialize tasks
---@param task_opts table<string, table>
---@param runner string
---@param output string
---@return Task[]
local init_tasks = function(task_opts, runner, output)
  local tasks = {}
  for id, task in pairs(task_opts) do
    tasks[id] = init_task(task, runner, output)
  end
  return tasks
end

--- Add type
---@param name string
---@param runner string | table
---@param output string | table
function M.add_type(name, runner, output)
  types[name] = Type:new(name, runner, output)
end

--- Add tasks
---@param type_name string
---@param selector_name string
---@param task_opts table
function M.add_tasks(type_name, selector_name, task_opts)
  local existing_type = types[type_name]
  assert(existing_type, "yabs: no type named " .. type_name)
  assert(core.runner_exists(existing_type.runner), "yabs: no runner named " .. (existing_type.runner or "nil"))
  local selector = init_selector(selector_name)
  local tasks = init_tasks(task_opts, existing_type.runner, existing_type.output)
  types[type_name]:add_tasks(tasks, selector)
end

--- Run task
---@param type_name string
---@param selector string | nil
---@param selection string | nil
function M.run_task(type_name, selector, selection)
  types[type_name]:run_task(selector, selection)
end

return M
