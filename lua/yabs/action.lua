local M = require("yabs.utils.class"):extend()
M.actions = {}

function M:init(options)
  self.name = options.name or 'Action'
  table.insert(M.actions, self)
end

if Debugging() then
  P(M.actions)
  local action1 = M {name = "one"}
  P(M.actions)
  local action2 = M {name = "two"}
  P(M.actions)
end

return M
