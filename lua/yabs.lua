local Output = require("yabs.output")

local M = {}

local runners = {}
local outputs = {}

function M.run_command(command, runner_opts, output_opts)
  local runner
  local runner_opts_type = type(runner_opts)
  if runner_opts_type == "string" then
    runner = runners[runner_opts]:new()
  elseif runner_opts_type == "table" then
    runner_name = runner_opts[1]
    runner_opts[1] = nil
    runner = runners[runner_name]:new(runner_opts)
  end

  local output
  local output_opts_type = type(output_opts)
  if output_opts_type == "string" then
    output = outputs[output_opts]:new()
  elseif output_opts_type == "table" then
    output_name = output_opts[1]
    output_opts[1] = nil
    output = outputs[output_name]:new(output_opts)
  end

  runner:run(command, output)
end

function M.register_runner(name, runner)
  runners[name] = runner
end

function M.register_output(name, output)
  outputs[name] = output
end

return M
