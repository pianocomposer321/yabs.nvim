local Path = require('plenary.path')

local defaults = {
  -- Database scheme:
  trusted = {},   -- { path = checksum }
  untrusted = {}, -- { path = checksum }
}

-- Simple implementation of a JSON database
--
-- This implementation should be sufficient for the simple task of verifying
-- trusted files (should be fast enough). It has the advantage of not requiring
-- any external dependencies besides plenary (which was already required), and
-- we're just using built-in libuv and JSON parser.
--
-- If more functionality is needed it may be good to move to some "real"
-- database in the future, e.g. using `tami5/sqlite.lua`.
local DataBase = {}
DataBase.__index = DataBase

-- Path to the database JSON file
function DataBase:path()
  return Path:new(vim.fn.stdpath('data')) / 'yabs.json'
end

-- Load the database from disk
function DataBase:load()
  local path = self:path()
  local ok, data = pcall(path.read, path)
  local tbl = ok and vim.json.decode(data) or {}
  return setmetatable({
    db = vim.tbl_extend('force', defaults, tbl),
  }, self)
end

-- Save the database to disk
function DataBase:save()
  self:path():write(vim.json.encode(self.db), 'w')
end

function DataBase:compute_checksum(fname)
  local path = Path:new(fname)
  local data = path:read()
  return vim.fn.sha256(data)
end

-- Convert a file path to filename used as key in the database
function DataBase:to_fname(path)
  return Path:new(path):absolute()
end

-- Remove information about a file from the database
function DataBase:reset(path)
  self.db.trusted[self:to_fname(path)] = nil
  self.db.untrusted[self:to_fname(path)] = nil
end

function DataBase:is_trusted(path)
  local fname = self:to_fname(path)

  -- Check if we already have db entry for this one
  -- Untrusted files should just be ignored
  if self.db.untrusted[fname] then
    return false
  end

  -- Trusted file requires that we verify the checksum
  local db_checksum = self.db.trusted[fname]
  local curr_checksum = self:compute_checksum(fname)
  if db_checksum == curr_checksum then
    return true
  end

  -- If checksums are different or there is no checksum, then we need
  -- to ask the user to trust the file.
  local msg = db_checksum and 'File changed on disk:' or 'Found new .yabs file:'
  -- TODO: use vim.ui.input; requires async-ifying the api
  local answer = vim.fn.input {
    prompt = string.format('%s\n%s\nAdd to trusted? [y/n]: ', msg, fname),
  }

  if vim.tbl_contains({'y', 'yes'}, answer:lower()) then
    vim.notify('\nAdding to trusted files: ' .. fname)
    self.db.trusted[fname] = curr_checksum
    self:save()
    return true
  elseif vim.tbl_contains({'n', 'no'}, answer:lower()) then
    vim.notify('\nAdding to untrusted files: ' .. fname)
    self.db.untrusted[fname] = curr_checksum
    self:save()
    return false
  else
    vim.notify('\nIgnoring file: ' .. fname)
    return false
  end
end

return DataBase
