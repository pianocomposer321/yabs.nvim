local yabs_core = require("yabs.core")

local M = {}

function M.setup()
  local runners = {"terminal", "system", "ex"}
  local outputs = {"quickfix", "echo"}

  for _, runner in ipairs(runners) do
    yabs_core.register_runner(runner, require("yabs.defaults.runners." .. runner))
  end

  for _, output in ipairs(outputs) do
    yabs_core.register_output(output, require("yabs.defaults.outputs." .. output))
  end
end

return M
