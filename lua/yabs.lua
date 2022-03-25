local M = {}

M.setup = function(config)
  print("setting up")
  P(config)
end

if Debugging() then
  M.setup({})
end

return M
