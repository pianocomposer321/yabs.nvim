local Output = require("yabs.core.output")

local api = vim.api

local Buffer = Output:new()

local function buffer_visible(bufnr)
  for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
    local winbufnr = api.nvim_win_get_buf(winid)
    if winbufnr == bufnr then
      return true
    end
  end
  return false
end

function Buffer:open()
end

function Buffer:init()
  self.listed = self.opts.listed or false
  self.scratch = self.opts.scratch or true
  self.bufnr = api.nvim_create_buf(self.listed, self.scratch)
  self.dir = self.opts.dir or "bot"
  local default_size = ""
  if self.dir == "bot" then
    default_size = 14
  end
  self.size = self.opts.size or default_size
end

function Buffer:recieve(data)
  local data = vim.split(data, "\n")
  api.nvim_buf_set_lines(self.bufnr, -1, -1, false, data)
end

return Buffer
