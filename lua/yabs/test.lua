local yabs = require("yabs")
local Output = require("yabs.output")
local Runner = require("yabs.runner")

local system = function(command, output)
  local result = vim.fn.system(command)
  output:recieve(result)
end

local Echo = Output:new()

function Echo:recieve(data)
  local opts = self.opts or {}
  if opts.inspect then
    P(data)
  else
    print(data)
  end
end

local System = Runner:new()

function System:run(output)
  local command = self.command
  local args = self.args
  if args then
    command = vim.tbl_flatten {command, args}
  end
  local data = vim.fn.system(command)
  output:recieve(data)
end

yabs.register_runner("system", System)
yabs.register_output("echo", Echo)

require("yabs-plenary").setup()
local Quickfix = require("yabs-defaults.outputs.quickfix")
yabs.register_output("quickfix", Quickfix)

yabs.run_commands {
  { {"bash", "-c", "echo start && sleep 2 && echo end"}, "plenary", "quickfix" },
  { {"bash", "-c", "echo hello, world"}, "plenary", "quickfix" },
  { {"bash", "-c", "echo hello, world"}, "system", {"echo", inspect = true} }
}
