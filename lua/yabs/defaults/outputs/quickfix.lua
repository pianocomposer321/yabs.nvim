local Quickfix = require("yabs.core.output"):new()

local function setqflist(list, action, opts)
  vim.schedule(function()
    vim.fn.setqflist(list, action, opts)
  end)
end

local function schedule_fn(fn, args)
  vim.schedule(function()
    vim.fn[fn](unpack(args))
  end)
end

local function cmd(c)
  vim.schedule(function()
    vim.api.nvim_command(c)
  end)
end

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
