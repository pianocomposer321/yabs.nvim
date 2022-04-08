local yabs = require("yabs")
local Output = require("yabs.output")
local Runner = require("yabs.runner")

local system = function(command, output)
  local result = vim.fn.system(command)
  output:recieve(result)
end

local Echo = Output:new()

function Echo:recieve(data)
  P(data)
end

local System = Runner:new()

function System:run(command, output)
  local data = vim.fn.system(command)
  output:recieve(data)
end

local echo_output = Echo:new()
local system_runner = System:new()

system_runner:run("echo hello, world", echo_output)
-- echo_output:recieve("hello, world")

-- yabs.register_output("buffer", Echo)
-- yabs.register_runner("system", System)
