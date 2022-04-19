local yabs_core = require("yabs.core")
local yabs_tasks = require("yabs.tasks")

local M = {}

function M.setup()
  local runners = {"terminal", "system", "ex"}
  local outputs = {"quickfix", "echo"}
  local selectors = {"filetype"}

  for _, runner in ipairs(runners) do
    yabs_core.register_runner(runner, require("yabs.defaults.runners." .. runner))
  end

  for _, output in ipairs(outputs) do
    yabs_core.register_output(output, require("yabs.defaults.outputs." .. output))
  end

  for _, selector in ipairs(selectors) do
    yabs_tasks.register_selector(selector, require("yabs.defaults.selectors." .. selector))
  end
end

return M
