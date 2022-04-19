local core = require("yabs.core")
local utils = require("yabs.utils")

local M = {}

--- Change from (command, runner, output) format to (command, args, runner, runner_opts, output, output_opts) format
---@param command string
---@param runner string | table
---@param output string | table
---@return table
local format = function(command, runner, output)
  local args
  command, args = utils.extract_command_and_args(command)
  local runner_opts
  runner, runner_opts = utils.extract_name_and_opts(runner)
  local output_opts
  output, output_opts = utils.extract_name_and_opts(output)
  return {command, args, runner, runner_opts, output, output_opts}
end

--- Run command
---@param command string
---@param runner string | table
---@param output string | table
function M.run_command(command, runner, output)
  core.run_command(unpack(format(command, runner, output)))
end

--- Run commands
---@param args table
function M.run_commands(args)
  local formatted = vim.tbl_map(function(arg)
    return format(unpack(arg))
  end, args)
  core.run_commands(formatted)
end

return M
