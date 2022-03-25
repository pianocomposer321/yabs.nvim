local M = require("yabs.utils.class"):extend()
M.languages = {}

function M:__tostring()
  return self.name
end

function M:init(options)
  self.options = options or {}
  self.name = self.options.name or 'Language'
  table.insert(M.languages, self)
end

if Debugging() then
  local lang = M {
    name = "lua"
  }
  P(lang)
  print(lang)
end

return M
