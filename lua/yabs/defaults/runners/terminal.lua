local Runner = require("yabs.core.runner")

---@class Terminal : Runner
---@field bufnr number
---@field channel number
local Terminal = Runner:new()

local api = vim.api

local cur_term = {}

local function buf_is_valid(buf)
  return buf and api.nvim_buf_is_valid(buf)
end

local function open_terminal(command, dir, size)
  api.nvim_command(dir .. " " .. size .. "new")
  return vim.fn.termopen(command)
end

function Terminal:init()
  self.command = table.concat(vim.tbl_flatten {self.command, self.args}, " ")
  self.dir = self.opts.dir or "bot"
  self.size = self.opts.size or 12

  local create = self.opts.create

  if create == nil or create == "auto" then
    create = not buf_is_valid(cur_term.bufnr)
  end

  if create then
    self.channel = open_terminal(vim.o.shell, self.dir, self.size)
    self.bufnr = api.nvim_get_current_buf()
    cur_term = self
  else
    self.channel = cur_term.channel
    self.bufnr = cur_term.bufnr
  end
end

function Terminal:run()
  assert(buf_is_valid(self.bufnr),
    "yabs.defaults(terminal): buffer not valid: " .. (self.bufnr or "nil"))
  vim.fn.chansend(self.channel, self.command .. "\n")
end

return Terminal
