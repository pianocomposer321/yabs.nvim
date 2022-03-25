local M = require("yabs.utils.class"):extend()
M.languages = {}

function M:__tostring()
  return self.name .. ": " .. vim.inspect(self)
end

function M:init(options)
  self.options = options or {}
  self.name = self.options.name or 'Language'
  table.insert(M.languages, self)
end

if Debugging() then
  local c = M {
    actions = {
      build = "gcc src/main.c -o bin/main",
      run = "./main",
      __outputs = {
        build = "quickfix",
        run = "terminal"
      }
    }
  }
end

return M
