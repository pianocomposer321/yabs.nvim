---@class Output
---@field opts table<string, any>
---@field command string
---@field args string[]
local Output = {}

local function init(output, args)
  for key, value in pairs(args) do
    output[key] = value
  end
end

--- Initialize output. This function is meant to be overridden.
function Output:init() end

--- Instantiate output. This function is not meant to be overridden.
---@param opts table<string, any>
---@param command string
---@param args string[]
---@return Output
function Output:new(opts, command, args)
  local new_output = setmetatable({}, { __index = self })
  init(new_output, {
    opts = opts or {},
    command = command,
    args = args
  })
  new_output:init()
  return new_output
end

--- Recieve data. This function is meant to be overridden.
---@param data string
function Output:recieve(data) end

return Output
