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

function Runner:init() end

function Runner:new(opts, command, args)
  local new_runner = setmetatable({}, { __index = self })
  init(new_runner, {
    opts = opts,
    command = command,
    args = args
  })
  new_runner:init()
  if new_runner.status and not new_runner.callbacks then new_runner.callbacks = {} end
  return new_runner
end

function Runner:run(output) end

function Runner:set_status(new_status)
  for _, callback in ipairs(self.callbacks) do
    callback(self.status, new_status)
  end
  self.status = new_status
end

function Runner:on_status_changed(callback)
  assert(self.status, "yabs: this runner does not support statuses")
  table.insert(self.callbacks, callback)
end

return Runner
