local function echo(cmd)
    print(vim.fn.system(cmd))
end

return echo
