local channel = nil
local bufnr = nil

local function terminal(cmd)
    ::retry::
    if channel == nil then
        vim.cmd("bot 10new")
        channel = vim.fn.termopen(vim.env.SHELL)
        bufnr = vim.fn.bufnr()
    end
    if not pcall(vim.fn.chansend, channel, cmd .. "\n") then
        channel = nil
        goto retry
    end

    vim.cmd("autocmd! TermClose <buffer> " .. bufnr .. "bd!")

    vim.cmd("starti")
end

local Output = require("yabs.output")
return Output:new(terminal)
