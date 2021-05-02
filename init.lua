local U = require("yabs/config")

vim.cmd("augroup yabs")
vim.cmd("au!")
vim.cmd("au BufRead,BufNewFile .yabs set ft=lua")
vim.cmd("augroup end")

local M = {
    build_func = nil,
    languages = {},
    default_language = nil,
    override_language = nil,
    did_config = false,
    did_setup = false
}

function M:setup(opts)
    self.build_func = U.create_config(opts).build_func
    self.did_setup = true
end

function M:build()
    if not self.did_config then
        self:load_config_file()
    end
    if not self.did_setup then
        self:setup()
    end

    if self.override_language then
        self.override_language:build()
        return
    end

    local ft = vim.bo.ft
    local current_language = self.languages[ft]
    if current_language then
        current_language:build()
    elseif self.default_language then
        self.default_language:build()
    end
end

local function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function M:load_config_file()
    if file_exists(".yabs") then
        vim.cmd("luafile .yabs")
        self.did_config = true
        return true
    else
        self.did_config = true
        return false
    end
end

M.Language = require("yabs/language")

return M
