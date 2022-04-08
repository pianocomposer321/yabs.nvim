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

function System:run(command, args, output)
  if args then
    command = vim.tbl_flatten {command, args}
  end
  local data = vim.fn.system(command)
  output:recieve(data)
end

-- local echo_output = Echo:new()
-- local system_runner = System:new()

-- system_runner:run("echo hello, world", echo_output)
-- echo_output:recieve("hello, world")

yabs.register_runner("system", System)
yabs.register_output("echo", Echo)

yabs.run_command({"bash", "-c", "echo hi"}, "system", {"echo", inspect = true})
