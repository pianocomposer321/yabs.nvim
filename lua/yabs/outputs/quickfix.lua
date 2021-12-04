local open_on_run
local dir

local function on_read(lines)
  for index, line in ipairs(lines) do
    if index == #lines and line == '' then
      goto continue
    end

    vim.fn.setqflist({}, 'a', { lines = { line } })
    if open_on_run == 'auto' then
      vim.api.nvim_command(dir .. ' copen')
      vim.api.nvim_command('wincmd p')
    end

    ::continue::
  end
end

local function quickfix(cmd, opts)
  vim.fn.setqflist({}, ' ', { title = cmd })

  opts = opts or {}

  local config = require('yabs.config')
  local quickfix_config = config.opts.output_types.quickfix

  open_on_run = opts.open_on_run or quickfix_config.open_on_run or 'auto'

  dir = opts.dir or quickfix_config.dir or 'bot'

  local on_exit = opts.on_exit

  if open_on_run == 'always' then
    vim.api.nvim_command(dir .. ' copen')
    vim.api.nvim_command('wincmd p')
  end

  require('yabs.utils').async_command(cmd, {
    on_read = on_read,
    on_exit = on_exit,
  })
end

local Output = require('yabs.output')
return Output:new(quickfix)
