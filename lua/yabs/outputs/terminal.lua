local channel = nil
local bufnr = nil

local function terminal(cmd, opts)
  opts = opts or {}
  ::retry::
  if channel == nil then
    vim.api.nvim_command('bot 10new')
    local termopen_opts = {}
    termopen_opts.on_exit = opts.on_exit or nil
    channel = vim.fn.termopen(vim.env.SHELL, termopen_opts)
    bufnr = vim.fn.bufnr()
  end
  if not pcall(vim.fn.chansend, channel, cmd .. '\n') then
    channel = nil
    goto retry
  end

  vim.api.nvim_command('autocmd! TermClose <buffer> ' .. bufnr .. 'bd!')

  vim.api.nvim_command('starti')
end

local Output = require('yabs.output')
return Output:new(terminal)
