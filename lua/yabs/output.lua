local Output = {}

local function init(output, args)
  for key, value in pairs(args) do
    output[key] = value
  end
end

function Output:init() end

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

function Output:recieve(data)
end

return Output
