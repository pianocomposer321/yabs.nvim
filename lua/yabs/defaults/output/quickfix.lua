local open = false
local function on_read(lines)
    for index, line in ipairs(lines) do
        if index == #lines and line == "" then goto continue end

        vim.fn.setqflist({}, "a", {lines = {line}})
        if not open then
            open = true
            vim.cmd("bot copen")
            vim.cmd("wincmd p")
        end

        ::continue::
    end
end

local function quickfix(cmd)
    vim.fn.setqflist({}, " ")

    require("yabs/util").async_command(cmd, {
        on_read = on_read
    })
end

return quickfix
