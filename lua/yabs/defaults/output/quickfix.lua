local results = {}

local function on_exit()
    vim.fn.setqflist({}, " ", {lines = results, nr = "$"})
    vim.cmd("copen")

    results = {}
end

local function on_read(lines)
    for index, line in ipairs(lines) do
        if index == #lines and line == "" then goto continue end

        table.insert(results, line)

        ::continue::
    end
end

local function quickfix(cmd)
    require("yabs/util").async_command(cmd, {
        on_exit = on_exit,
        on_read = on_read
    })
end

return quickfix
