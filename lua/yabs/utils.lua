local M = {}

function M.extract_name_and_opts(opts)
  local opts_type = type(opts)
  if opts_type == "string" then
    return opts
  elseif opts_type == "table" then
    local name = opts[1]
    opts[1] = nil
    return name, opts
  end
end

return M
