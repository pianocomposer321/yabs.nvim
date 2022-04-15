local Output = require("yabs.core.output")

local M = {}

local runners = {}
local outputs = {}

local extract_name_and_opts = function(opts)
  local opts_type = type(opts)
  if opts_type == "string" then
    return opts
  elseif opts_type == "table" then
    local name = opts[1]
    opts[1] = nil
    return name, opts
  end
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

local init_runner = function(command, args, opts)
  local name, opts = extract_name_and_opts(opts)
  return runners[name]:new(opts, command, args)
end

local init_output = function(command, args, opts)
  if not opts then return Output:new() end
  local name, opts = extract_name_and_opts(opts)
  return outputs[name]:new(opts, command, args)
end

function M.run_command(command, runner_opts, output_opts)
  local args
  command, args = extract_command_and_args(command)
  local runner = init_runner(command, args, runner_opts)
  local output = init_output(command, args, output_opts)
  runner:run(output)
end

function M.run_commands(commands)
  local runner_opts = vim.tbl_map(function(command_options)
    local command, args = extract_command_and_args(command_options[1])
    local runner_opts = command_options[2]
    return {command, args, runner_opts}
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
