local open_on_run

local open = false
local function on_read(lines)
    for index, line in ipairs(lines) do
        if index == #lines and line == "" then goto continue end

        vim.fn.setqflist({}, "a", {lines = {line}})
        if not open and open_on_run == "auto" then
            open = true
            vim.cmd("bot copen")
            vim.cmd("wincmd p")
        end

        ::continue::
    end
end

local function quickfix(cmd, opts)
    vim.fn.setqflist({}, " ")

    opts = opts or {}
    open_on_run = opts.open_on_run or require("yabs.config").output_types.quickfix.open_on_run
    if open_on_run == "always" then
        vim.cmd("bot copen")
        vim.cmd("wincmd p")
    end

    require("yabs/util").async_command(cmd, {
        on_read = on_read
    })
end

return quickfix
