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

M.Language = require("yabs/language")

function M:setup(opts)
    self.build_func = U.create_config(opts).build_func
    local languages = opts.languages or {}

    for name, build_command in pairs(languages) do
        local default = false
        local override = false
        local command

        if type(build_command) == "table" then
            if build_command.default ~= nil then default = build_command.default end
            if build_command.override ~= nil then override = build_command.override end
            command = build_command[1]
        else
            command = build_command
        end

        local language = self.Language:new {
            name = name,
            command = command
        }
        language:setup(self, {
            default = default,
            override = override
        })
    end
    self.did_setup = true
end

function M:add_language(name, command, override, default)
    local language = M.Language:new {
        name = name,
        command = command
    }
    language:setup(self, {override = override, default = default})
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

return M
