local Path = require('plenary.path')

local defaults = {
  trusted = {},
  untrusted = {},
}

local DataBase = {}
DataBase.__index = DataBase

function DataBase:path()
  return Path:new(vim.fn.stdpath('data')) / 'yabs.json'
end

function DataBase:load()
  local path = self:path()
  local ok, data = pcall(path.read, path)
  local tbl = ok and vim.json.decode(data) or {}
  return setmetatable({
    db = vim.tbl_extend('force', defaults, tbl),
  }, self)
end

function DataBase:save()
  self:path():write(vim.json.encode(self.db), 'w')
end

function DataBase:is_trusted(path)
  local fname = path:absolute()

  -- Check if we already have db entry for this one
  if vim.tbl_contains(self.db.untrusted, fname) then
    return false
  elseif vim.tbl_contains(self.db.trusted, fname) then
    return true
  end

  -- If not then ask user what to do
  -- TODO: use vim.ui.input; requires async-ifying the api
  local answer = vim.fn.input {
    prompt = string.format('Found .yabs file:\n%s\nAdd to trusted? [y/n]: ', fname),
  }

  if vim.tbl_contains({'y', 'yes'}, answer:lower()) then
    vim.notify('\nAdding to trusted files: ' .. fname)
    table.insert(self.db.trusted, fname)
    self:save()
    return true
  elseif vim.tbl_contains({'n', 'no'}, answer:lower()) then
    vim.notify('\nAdding to untrusted files: ' .. fname)
    table.insert(self.db.untrusted, fname)
    self:save()
    return false
  else
    vim.notify('\nIgnoring file: ' .. fname)
    return false
  end
end

return DataBase
