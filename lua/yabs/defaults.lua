local outputs = {}
local tasks = {}

outputs.ex = vim.cmd
outputs.echo = function(cmd)
  vim.cmd("!" .. cmd)
end

local expand = vim.fn.expand

local placeholders = {
  file = function()
    return expand("%:.")
  end,
  file_abs = function()
    return expand("%:p")
  end,
  file_noext = function()
    return expand("%:r")
  end,
  file_ext = function()
    return expand("%:e")
  end,
  expand = function(args)
    if args[2] then
      return expand(args[1] .. ":" .. args[2])
    else
      return expand("%:", args[1])
    end
  end
}

tasks.source = "source #{FILE}"
tasks.__outputs = {source = "ex"}

return {
  outputs = outputs,
  placeholders = placeholders,
  tasks = tasks
}
