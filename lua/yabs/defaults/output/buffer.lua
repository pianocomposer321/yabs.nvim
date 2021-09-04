local function buffer(cmd)
    vim.cmd("bot 13new")
    vim.fn.termopen(cmd)
    vim.cmd("starti")
end

return buffer
