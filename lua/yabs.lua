local core = require("yabs.core")
local utils = require("yabs.utils")

local M = {}

local format = function(command, runner, output)
  local args
  command, args = utils.extract_command_and_args(command)
  local runner_opts
  runner, runner_opts = utils.extract_name_and_opts(runner)
  local output_opts
  output, output_opts = utils.extract_name_and_opts(output)
  return {command, args, runner, runner_opts, output, output_opts}
end

function M.run_command(command, runner, output)
  core.run_command(unpack(format(command, runner, output)))
end

function M.run_commands(args)
  local formatted = vim.tbl_map(function(arg)
    return format(unpack(arg))
  end, args)
  core.run_commands(formatted)
end

return M
