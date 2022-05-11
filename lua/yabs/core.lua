local Output = require("yabs.core.output")
local Runner = require("yabs.core.runner")

local M = {}

---@type table<string, Runner>
local runners = {}
---@type table<string, Output>
local outputs = {}

--- Get runner with name `runner`
---@param runner string | Runner
---@return Runner | nil
function M.get_runner(runner)
  local runner_type = type(runner)
  if runner_type == "string" then
    return assert(runners[runner], "yabs: no runner named " .. runner)
  elseif runner_type == "table" then
    return runner
  end
end

--- Check whether runner with name `name` runner_exists
---@param name string
---@return boolean
function M.runner_exists(name)
  return runners[name] ~= nil
end

--- Get output with name `output`
---@param output string | Output
---@return Output | nil
function M.get_output(output)
  local output_type = type(output)
  if output_type == "string" then
    return assert(outputs[output], "yabs: no output named " .. output)
  elseif output_type == "table" then
    return output
  end
end

--- Initialize new stateless runner. Basically creates new runner with `runner` as its `run` method, but does not add it to `runners` table.
---@param runner fun(command: string, args: string[], output: Output)
---@param command string
---@param args string[]
---@return Runner
local stateless_runner = function(runner, command, args)
  local new_runner = Runner:new(nil, command, args)
  function new_runner:run(output)
    runner(command, args, output)
  end
  return new_runner
end

--- Initialize new runner from those registered in `runners`.
---@param name string
---@param opts table<string, any>
---@param command string
---@param args string[]
---@return Runner
local stateful_runner = function(name, opts, command, args)
  return runners[name]:new(opts, command, args)
end

--- Initialize runner
---@param runner fun(command: string, args: string[], output: Output) | string
---@param runner_opts table<string, any>
---@param command string
---@param args string[]
function M.init_runner(runner, runner_opts, command, args)
  if type(runner) == "function" then
    return stateless_runner(runner, command, args)
  else
    return stateful_runner(runner, runner_opts, command, args)
  end
end

--- Initialize new stateless output.
---@see stateless_runner
---@param output fun(data: string, command: string, args: string[])
---@param command string
---@param args string[]
---@return Output
local stateless_output = function(output, command, args)
  local new_output = Output:new(nil, command, args)
  function new_output:recieve(data)
    output(data, command, args)
  end
  return new_output
end

--- Initialize new statefule output
---@see stateful_runner
---@param name string
---@param opts table<string, any>
---@param command string
---@param args string[]
---@return Output
local stateful_output = function(name, opts, command, args)
  return outputs[name]:new(opts, command, args)
end

--- Initialize output
---@param output fun(data: string, command: string, args: string[]) | string
---@param output_opts table<string, any>
---@param command string
---@param args string[]
function M.init_output(output, output_opts, command, args)
  if not output then return Output:new() end
  local output_type = type(output)
  if output_type == "function" then
    return stateless_output(output, command, args)
  else
    return stateful_output(output, output_opts, command, args)
  end
end

--- Run command
---@param command string
---@param args string[]
---@param runner_name fun(command: string, args: string[], output: Output) | string
---@param runner_opts table<string, any>
---@param output_name fun(data: string, command: string, args: string[]) | string
---@param output_opts table<string, any>
function M.run_command(command, args, runner_name, runner_opts, output_name, output_opts)
  assert(runners[runner_name], "yabs: no runner named " .. runner_name)
  assert(outputs[output_name], "yabs: no output named " .. output_name)
  local runner = M.init_runner(runner_name, runner_opts, command, args)
  local output = M.init_output(output_name, output_opts, command, args)
  runner:run(output)
end

--- Run commands.
---@param args table
function M.run_commands(args)
  local commands = vim.tbl_map(function(opts)
    return opts[1]
  end, args)
  local command_args = vim.tbl_map(function(opts)
    return opts[2]
  end, args)
  local l_runners = vim.tbl_map(function(opts)
    return opts[3]
  end, args)
  local runner_opts = vim.tbl_map(function(opts)
    return opts[4]
  end, args)
  local l_outputs = vim.tbl_map(function(opts)
    return opts[5]
  end, args)
  local outout_opts = vim.tbl_map(function(opts)
    return opts[6]
  end, args)

  local statuses = require("yabs.core.runner").__statuses

  local run_command_at_index
  run_command_at_index = function(index)
    local cur_command = commands[index]
    local cur_args = command_args[index]
    local cur_runner = M.init_runner(l_runners[index], runner_opts[index], cur_command, cur_args)
    local cur_output = M.init_output(l_outputs[index], outout_opts[index], cur_command, cur_args)

    if runner_opts[index + 1] then
      cur_runner:on_status_changed(function(from, to)
        if from ~= statuses.RUNNING then
          return
        end
        if vim.tbl_contains({statuses.EXITED, statuses.SUCCESS}, to) then
          run_command_at_index(index + 1)
        end
      end)
    end
    cur_runner:run(cur_output)
  end

  run_command_at_index(1)
end

--- Register runner.
---@param name string
---@param runner Runner
function M.register_runner(name, runner)
  local runner_type = type(runner)
  assert(runner_type == "table", "yabs: type(runner): expected table, found " .. runner_type)
  runners[name] = runner
end

--- Register output
---@param name string
---@param output Output
function M.register_output(name, output)
  outputs[name] = output
end

return M
