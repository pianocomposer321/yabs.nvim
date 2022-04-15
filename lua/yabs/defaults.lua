local yabs = require("yabs.core")

local M = {}

function M.setup()
  local runners = {"terminal", "system"}
  local outputs = {"quickfix", "echo"}

  for _, runner in ipairs(runners) do
    yabs.register_runner(runner, require("yabs.defaults.runners." .. runner))
  end

  for _, output in ipairs(outputs) do
    yabs.register_output(output, require("yabs.defaults.outputs." .. output))
  end
end

return M
