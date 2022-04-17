local utils = require("yabs.utils")
local core = require("yabs.core")

local Task = {}

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

function Task:run()
  local runner, runner_opts = utils.extract_name_and_opts(self.runner)
  local output, output_opts = utils.extract_name_and_opts(self.output)
  core.run_command(self.command, self.args, runner, runner_opts, output, output_opts)
end

return Task
