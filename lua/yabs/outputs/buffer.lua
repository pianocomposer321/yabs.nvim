local utils = require('yabs.utils')
local Job = require('plenary.job')

local function make_scratch_buffer(height, position)
  if not height then
    height = ''
  end
  if not position then
    position = ''
  else
    position = position .. ' '
  end
  vim.api.nvim_command(position .. height .. 'new')

  vim.opt_local.buftype = 'nofile'
  vim.opt_local.bufhidden = 'wipe'
  vim.opt_local.buflisted = false
  vim.opt_local.swapfile = false
  vim.opt_local.wrap = false

  return vim.fn.bufnr()
end

local bufnr

local function append_to_buffer(error, data)
  vim.api.nvim_buf_set_lines(bufnr, -2, -2, false, { error and error or data })
end

local function buffer(cmd, opts)
  opts = opts or {}
  bufnr = make_scratch_buffer(14, 'bot')

  local splitted_cmd = utils.split_cmd(cmd)
  local job = Job:new({
    command = table.remove(splitted_cmd, 1),
    args = splitted_cmd,
    on_exit = opts.on_exit,
    on_stdout = vim.schedule_wrap(append_to_buffer),
    on_stderr = vim.schedule_wrap(append_to_buffer),
  })
  job:start()
end

local Output = require('yabs.output')
return Output:new(buffer)
