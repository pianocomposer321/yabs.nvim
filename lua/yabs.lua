local Output = require("yabs.output")

local M = {}

local runners = {}
local outputs = {}

local extract_from_opts = function(opts)
  local opts_type = type(opts)
  if opts_type == "string" then
    return opts
  elseif opts_type == "table" then
    local name = opts[1]
    opts[1] = nil
    return name, opts
  end
end

function M.run_command(command, runner_opts, output_opts)
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

  local runner_name, runner_opts = extract_from_opts(runner_opts)
  local runner = runners[runner_name]:new(runner_opts)

  local output_name, output_opts = extract_from_opts(output_opts)
  local output = outputs[output_name]:new(output_opts)

  runner:run(command, args, output)
end

function M.register_runner(name, runner)
  runners[name] = runner
end

function M.register_output(name, output)
  outputs[name] = output
end

return M
