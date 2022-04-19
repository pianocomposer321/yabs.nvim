---@class Quickfix : Output
---@field dir string
---@field is_open boolean
---@field open_on_run Enum
local Quickfix = require("yabs.core.output"):new()

function Quickfix:open()
  vim.api.nvim_command(self.dir .. " copen")
  if not self.opts.focus then
    vim.api.nvim_command("wincmd p")
  end
  self.is_open = true
end

function Quickfix:init()
  self.opts = self.opts or {}
  self.open_on_run = self.opts.open_on_run or "auto"
  self.dir = self.opts.dir or "bot"
  self.is_open = false

  local cmd = table.concat(vim.tbl_flatten { self.command, self.args }, " ")
  vim.fn.setqflist({}, " ", { title = cmd })

  if self.open_on_run == "always" then
    self:open()
  end
end

function Quickfix:recieve(data)
  vim.fn.setqflist({}, "a", { lines = { data } })
  if self.open_on_run == "auto" and not self.is_open then
    self:open()
  end
end

return Quickfix
