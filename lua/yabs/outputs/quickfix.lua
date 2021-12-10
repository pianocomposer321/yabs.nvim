local config = require('yabs.config')
local utils = require('yabs.utils')
local Job = require('plenary.job')

local open_on_run
local dir

local function append_to_quickfix(error, data)
  vim.fn.setqflist({}, 'a', { lines = { error and error or data } })
  if open_on_run == 'auto' then
    vim.api.nvim_command(dir .. ' copen')
    vim.api.nvim_command('wincmd p')
  end
end

local function quickfix(cmd, opts)
  opts = opts or {}

  vim.fn.setqflist({}, ' ', { title = cmd })

  local quickfix_config = config.opts.output_types.quickfix

  open_on_run = opts.open_on_run or quickfix_config.open_on_run or 'auto'
  dir = opts.dir or quickfix_config.dir or 'bot'

  if open_on_run == 'always' then
    vim.api.nvim_command(dir .. ' copen')
    vim.api.nvim_command('wincmd p')
  end

  local splitted_cmd = utils.split_cmd(cmd)
  local job = Job:new({
    command = table.remove(splitted_cmd, 1),
    args = splitted_cmd,
    on_stdout = vim.schedule_wrap(append_to_quickfix),
    on_stderr = vim.schedule_wrap(append_to_quickfix),
    on_exit = opts.on_exit,
  })
  job:start()
end

local Output = require('yabs.output')
return Output:new(quickfix)
