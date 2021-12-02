local channel = nil
local bufnr = nil

local function terminal(cmd)
  ::retry::
  if channel == nil then
    vim.api.nvim_command('bot 10new')
    channel = vim.fn.termopen(vim.env.SHELL)
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
