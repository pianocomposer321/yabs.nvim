local M = {}

local Language = require("yabs.language")

M.setup = function(config)
  for name, language_ in pairs(config.languages) do
    print(name)
    language_.name = language_.name or name
    local language = Language(language_)
  end
end

return M
