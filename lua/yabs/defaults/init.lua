-- type: "shell" (default) or "vim"
-- output: "buffer" (default), "terminal", "quickfix", "echo", or "none"

--[[
Yabs:setup {
    default_output = "terminal",
    languages = {
        lua = {
            build = "luafile %",
            type = "vim",
            default = true
        },
        python = {
            build = function()
                local file = vim.fn.expand("%:~:.")
                return "python3 " .. file
            end
        },
        cpp = {
            build = function()
                local file = vim.fn.expand("%:~:.")
                return "g++ " .. file .. " -std=c++17 -o " .. vim.fn.fnamemodify(file, ":r")
            end,
            output = "quickfix"
        }
    }
}
]]

local defaults = {
    default_output = nil,
    default_type = nil
}

defaults.output_types = {
    buffer = nil,
    terminal = nil,
    quickfix = nil,
    echo = nil,
    none = nil,
    consolation = nil
}

defaults.command_types = {
    shell = nil,
    vim = nil
}

defaults.output_types.buffer = require("yabs.defaults.output.buffer")
defaults.output_types.terminal = require("yabs.defaults.output.terminal")
defaults.output_types.quickfix = require("yabs.defaults.output.quickfix")
defaults.output_types.echo = require("yabs.defaults.output.echo")
defaults.output_types.consolation = require("yabs.defaults.output.consolation")

defaults.default_output = defaults.output_types.terminal
defaults.default_type = "shell"

return defaults
