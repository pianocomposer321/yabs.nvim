local utils = require("yabs.utils")
local core = require("yabs.core")

---@class Task
---@field command string
---@field args string[]
---@field runner string | table
---@field output string | table
---@filed opts table<string, any>
local Task = {}

--- Instantiate Task
---@param command string
---@param args string[]
---@param runner string | table
---@param output string | table
---@param opts table<string, any>
---@return Task
function Task:new(command, args, runner, output, opts)
  local new_task = setmetatable({
    command = command,
    args = args,
    runner = runner,
    output = output,
    opts = opts
  }, { __index = self })
  return new_task
end

--- Run task
function Task:run()
  local runner, runner_opts = utils.extract_name_and_opts(self.runner)
  local output, output_opts = utils.extract_name_and_opts(self.output)
  core.run_command(self.command, self.args, runner, runner_opts, output, output_opts)
end

return Task
