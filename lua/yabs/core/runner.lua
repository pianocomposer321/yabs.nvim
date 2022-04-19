---@alias Status number | nil
---@alias Callback fun(from: Status, to: Status)

--- Object to run class
---@class Runner
---@field __statuses table<string, number>
---@field status Status
---@field callbacks Callback[]
---@field opts table<string, any>
---@field command string
---@field args string[]
local Runner = {}
Runner.__statuses = {
  IDLE = 1,
  RUNNING = 2,
  SUCCESS = 3,
  FAILED = 4,
  EXITED = 5
}

local function init(runner, args)
  for key, value in pairs(args) do
    runner[key] = value
  end
end

--- Initialize runner. This function is meant to be overridden.
function Runner:init() end

--- Instantiate runner. This function should not be overridden.
---@param opts table<string, any>
---@param command string
---@param args string[]
---@return Runner
function Runner:new(opts, command, args)
  local new_runner = setmetatable({}, { __index = self })
  init(new_runner, {
    opts = opts or {},
    command = command,
    args = args
  })
  new_runner:init()
  if
    new_runner.status and not new_runner.callbacks
  then new_runner.callbacks = {} end
  return new_runner
end

--- Run self.command. This function is mean to be overridden.
---@param output Output
function Runner:run(output) end

--- Set status to `new_status` and trigger callbacks
---@param new_status Status
function Runner:set_status(new_status)
  for _, callback in ipairs(self.callbacks) do
    callback(self.status, new_status)
  end
  self.status = new_status
end

--- Add callback
---@param callback Callback
function Runner:on_status_changed(callback)
  assert(self.status, "yabs: this runner does not support statuses")
  table.insert(self.callbacks, callback)
end

return Runner
