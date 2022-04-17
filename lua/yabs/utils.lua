local M = {}

function M.extract_name_and_opts(opts)
  local opts_type = type(opts)
  if opts_type == "string" then
    return opts, {}
  elseif opts_type == "table" then
    local name = opts[1]
    opts[1] = nil
    return name, opts
  end
  return opts
end

function M.extract_command_and_args(command)
  local args
  local command_type = type(command)
  if command_type == "string" then
    local split = vim.split(command, " ")
    command = split[1]
    args = vim.list_slice(split, 2, #split)
  elseif command_type == "table" then
    args = vim.list_slice(command, 2, #command)
    command = command[1]
  end
  return command, args or {}
end

return M
