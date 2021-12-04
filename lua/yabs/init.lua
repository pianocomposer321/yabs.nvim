local Yabs = {
  default_output = nil,
  default_type = nil,
  languages = {},
  tasks = {},
}

local did_config = false
local did_setup = false

local Language = require('yabs.language')
local Task = require('yabs.task')
local utils = require('yabs.utils')
local scopes = Task.scopes

function Yabs.run_command(...)
  local args = { ... }
  local cmd = args[1]
  local output = args[2]
  local opts = args[3]

  output = output or Yabs.default_output
  utils.run_command(cmd, output, opts)
end

function Yabs.first_available(...)
  local tasks = { ... }
  return function()
    for _, task in ipairs(tasks) do
      local yabs_task = Yabs.tasks[task]
      if yabs_task ~= nil and not yabs_task.disabled then
        return task
      end
    end
  end
end

local function _set_output_type_configs(output_types)
  for output_type, config in pairs(output_types) do
    require('yabs.outputs')[output_type].config = config
  end
end

function Yabs:setup(values)
  local config = require('yabs.config')
  setmetatable(config, {
    __index = vim.tbl_extend('force', config.defaults, { opts = values.opts }),
  })
  values = vim.tbl_deep_extend('force', config, values or {})

  _set_output_type_configs(config.opts.output_types)

  local outputs = require('yabs.outputs')
  self.default_output = outputs[values.default_output] or self.default_output or config.output

  self.default_type = values.default_type or self.default_type or config.type

  -- Add all the languages
  values.languages = values.languages or {}
  for name, options in pairs(values.languages) do
    self:add_language(name, options)
  end

  -- Add tasks
  local tasks = values.tasks or {}
  for name, options in pairs(tasks) do
    self:add_task(name, options)
  end

  if values.default_task then
    self.default_task = values.default_task
  end

  did_setup = true
end

function Yabs:add_language(name, args)
  -- Creat a new language with `args` and call setup on it
  args.name = name
  args = vim.tbl_extend('keep', args, { output = self.default_output, type = self.default_type })
  local language = Language:new(args)
  -- TODO: remove this, override and default are deprecated
  language:setup(self, {
    override = args.override,
    default = args.default,
  })
end

function Yabs:get_current_language()
  local ft = vim.bo.ft
  return self.languages[ft]
end

function Yabs:add_task(name, args)
  assert(args.command, 'yabs: you must specify a command value for each task')
  args.name = name
  args = vim.tbl_extend('keep', args, { output = self.default_output, type = self.default_type })
  local task = Task:new(args)
  task:setup(self)
end

function Yabs:get_current_language_tasks()
  if not did_setup then
    return {}
  end
  local cur_lang = self:get_current_language()
  if not cur_lang then
    return {}
  end
  return cur_lang.tasks
end

function Yabs:get_global_tasks()
  return self.tasks
end

function Yabs:get_tasks(scope)
  if not scope then
    scope = scopes.ALL
  end

  if scope == scopes.GLOBAL then
    return self:get_global_tasks()
  end
  if scope == scopes.LOCAL then
    return self:get_current_language_tasks()
  end

  assert(scope == scopes.ALL, 'unsupported scope: ' .. scope)
  return vim.tbl_extend('keep', self:get_current_language_tasks(), self:get_global_tasks())
end

function Yabs:run_global_task(task, opts)
  assert(self.tasks[task], 'yabs: no global task named ' .. task)
  self.tasks[task]:run(opts)
end

function Yabs:_run_task_with_scope(task, scope, opts)
  local current_language = self:get_current_language()

  if scope == scopes.GLOBAL then
    self:run_global_task(task, opts)
  elseif scope == scopes.LOCAL then
    -- If the current filetype has a build command set up, run it
    assert(current_language and current_language:has_task(task), 'yabs: no local task named ' .. task)
    current_language:run_task(task, opts)
    return
  end
end

function Yabs:run_task(task, opts)
  if not opts then
    opts = {}
  end

  local current_language = self:get_current_language()

  -- If we haven't loaded the .yabs config file yet, load it (if it doesn't
  -- exist, this will fail silently)
  if not did_config then
    self:load_config_file()
  end
  -- If we haven't run the setup function yet, run it
  if not did_setup then
    self:setup()
  end

  if opts.scope and opts.scope ~= scopes.ALL then
    self:_run_task_with_scope(task, opts.scope, opts)
    return
  end

  -- If there is an override_language, run its build function and exit
  -- TODO: remove this, override and default languages are deprecated
  if self.override_language and self.override_language:has_task(task) then
    self.override_language:run_task(task)
    return
  end

  -- If the current filetype has a build command set up, run it
  if current_language and current_language:has_task(task) then
    current_language:run_task(task, opts)
    return
  end
  -- Otherwise, if there is a default_language set up, run its build command
  -- TODO: remove this, override and default languages are deprecated
  if self.default_language and self.default_language:has_task(task) then
    self.default_language:run_task(task)
    return
  end
  if self.tasks and self.tasks[task] then
    self:run_global_task(task, opts)
    return
  end

  utils.notify('No task named ' .. task, vim.log.levels.ERROR)
end

function Yabs:run_default_task()
  -- If we haven't loaded the .yabs config file yet, load it (if it doesn't
  -- exist, this will fail silently)
  if not did_config then
    self:load_config_file()
  end
  -- If we haven't run the setup function yet, run it
  if not did_setup then
    self:setup()
  end

  -- If there is an override_language, run its build function and exit
  -- TODO: remove this, override and default languages are deprecated
  if self.override_language then
    utils.notify(
      'yabs: deprecation notice: default and override languages are superceded by global tasks',
      vim.log.levels.WARN
    )
    self.override_language:run_default_task()
    return
  end

  local default_task

  if self.default_task then
    default_task = self.default_task
  end

  -- If the current filetype has a build command set up, run it
  local current_language = self:get_current_language()
  if current_language then
    default_task = current_language.default_task
  end

  if default_task then
    local task

    if type(default_task) == 'function' then
      task = default_task()
    else
      task = default_task
    end

    self:run_task(task)
    return
  end

  -- Otherwise, if there is a default_language set up, run its build command
  -- TODO: remove this, override and default languages are deprecated
  if self.default_language then
    utils.notify(
      'yabs: deprecation notice: default and override languages are superceded by global tasks',
      vim.log.levels.WARN
    )
    self.default_language:run_default_task()
  end
end

function Yabs:load_config_file()
  if utils.file_exists('.yabs') then
    local config = dofile(vim.loop.cwd() .. '/.yabs')
    if not config then
      utils.notify(
        'yabs: deprecation notice: calling `yabs:setup()` in a .yabs file is now deprecated.',
        vim.log.levels.WARN
      )
      utils.notify('consider returning the config from the file instead.', vim.log.levels.WARN)
    else
      self:setup(config)
    end
    did_config = true
    return true
  else
    did_config = true
    return false
  end
end

return Yabs
