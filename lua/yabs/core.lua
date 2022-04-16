local Output = require("yabs.core.output")
local Runner = require("yabs.core.runner")

local utils = require("yabs.utils")

local M = {}

local runners = {}
local outputs = {}

function M.get_runner(runner)
  if type(runner) == "string" then
    return runners[runner]
  end
  return runner
end

function M.get_output(output)
  return outputs[output]
end

local extract_command_and_args = function(command)
  local args
  local command_type = type(command)
  if command_type == "string" then
    local split = vim.split(command, " ")
    command = split[1]
    args = vim.list_slice(split, 2, #split)
  elseif command_type == "table" then
    args = vim.list_slice(command, 2, #command)
    command = command[1]
  end
  return command, args
end

local stateless_runner = function(runner, command, args)
  local new_runner = Runner:new(nil, command, args)
  function new_runner:run(output)
    runner(command, args, output)
  end
  return new_runner
end

local stateful_runner = function(runner, command, args)
  local runner_type = type(runner)
  local name, opts
  if runner_type == "table" then
    name, opts = utils.extract_name_and_opts(runner)
  elseif runner_type == "string" then
    name = runner
  end
  return runners[name]:new(opts, command, args)
end

local init_runner = function(runner, command, args)
  if type(runner) == "function" then
    return stateless_runner(runner, command, args)
  else
    return stateful_runner(runner, command, args)
  end
end

local stateless_output = function(output, command, args)
  local new_output = Output:new(nil, command, args)
  function new_output:recieve(data)
    output(data, command, args)
  end
  return new_output
end

local stateful_output = function(output, command, args)
  local output_type = type(output)
  local name, opts
  if output_type == "table" then
    name, opts = utils.extract_name_and_opts(output)
  elseif output_type == "string" then
    name = output
  end
  return outputs[name]:new(opts, command, args)
end

local init_output = function(command, args, output)
  if not output then return Output:new() end
  local output_type = type(output)
  if output_type == "function" then
    return stateless_output(output, command, args)
  else
    return stateful_output(output, command, args)
  end
  local name, opts = utils.extract_name_and_opts(output)
  return outputs[name]:new(opts, command, args)
end

function M.run_command(command, runner_opts, output_opts)
  local args
  command, args = extract_command_and_args(command)
  local runner = init_runner(runner_opts, command, args)
  local output = init_output(command, args, output_opts)
  runner:run(output)
end

function M.run_commands(commands)
  local runner_opts = vim.tbl_map(function(command_options)
    local command, args = extract_command_and_args(command_options[1])
    local runner_opts = command_options[2]
    return {runner_opts, command, args}
  end, commands)
  local output_opts = vim.tbl_map(function(command_options)
    local command, args = extract_command_and_args(command_options[1])
    local output_opts = command_options[3]
    return {command, args, output_opts}
  end, commands)

  local statuses = require("yabs.core.runner").__statuses

  local run_command_at_index
  run_command_at_index = function(index)
    local cur_runner = init_runner(unpack(runner_opts[index]))
    local cur_output = init_output(unpack(output_opts[index]))

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

function M.register_runner(name, runner)
  runners[name] = runner
end

function M.register_output(name, output)
  outputs[name] = output
end

return M
