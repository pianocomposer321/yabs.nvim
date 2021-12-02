local Task = {
  scopes = {
    GLOBAL = 1,
    LOCAL = 2,
    ALL = 3,
  },
}

function Task:new(args)
  local state = {
    name = args.name,
    command = args.command,
    type = args.type,
    output = args.output,
    condition = args.condition,
    disabled = false,
    opts = args.opts or {},
  }

  self.__index = self
  return setmetatable(state, self)
end

function Task:setup(parent)
  assert(self.output, 'yabs: output for task ' .. self.name .. ' is nil')
  assert(self.type, 'yabs: type for task ' .. self.name .. ' is nil')

  if self.condition then
    self.disabled = not self.condition()
  end

  parent.tasks[self.name] = self
end

function Task:run(opts)
  if self.disabled then
    return
  end

  local command
  if type(self.command) == 'function' then
    -- If `self.command` is a function, command is its return value
    command = self.command()
    -- If `self.type` is lua, the only thing we need to do is execute the
    -- command as a function
    if self.type == 'lua' then
      return
    end
  else
    command = self.command
  end

  command = require('yabs.util').expand(command)

  if self.type == 'vim' then
    vim.api.nvim_command(command)
  elseif self.type == 'shell' then
    opts = opts or {}
    opts = vim.tbl_extend('keep', opts, self.opts)
    require('yabs.util').run_command(command, self.output, opts)
  end
end

return Task
