local M = {}

function M.expand(str)
  -- Expand % strings and wildcards anywhere in string
  local split_str = vim.split(str, ' ')
  local expanded_str = vim.tbl_map(vim.fn.expand, split_str)
  return table.concat(expanded_str, ' ')
end

function M.run_command(cmd, output, opts)
  cmd = M.expand(cmd)
  opts = opts or {}

  local output_types = require('yabs.outputs')
  if type(output) == 'function' then
    output(cmd, opts)
    return
  end

  if type(output) == 'string' then
    output = output_types[output]
  end

  output:run(cmd, opts)
end

function M.file_exists(file)
  local f = io.open(file, 'rb')
  if f then
    f:close()
  end
  return f ~= nil
end

function M.notify(msg, log_level)
  vim.notify(msg, log_level, { title = 'Yabs' })
end

function M.split_cmd(cmd)
  if not cmd then
    return {}
  end

  -- Split on spaces unless "in quotes"
  local splitted_cmd = vim.fn.split(cmd, [[\s\%(\%([^'"]*\(['"]\)[^'"]*\1\)*[^'"]*$\)\@=]])

  -- Remove quotes
  for i, arg in ipairs(splitted_cmd) do
    splitted_cmd[i] = arg:gsub('"', ''):gsub("'", '')
  end
  return splitted_cmd
end

return M
