local stdout
local stderr
local handle

local results = {}

local function on_exit()
    stdout:read_stop()
    stderr:read_stop()

    stdout:close()
    stderr:close()

    handle:close()

    vim.fn.setqflist({}, " ", {title = "yabs.nvim output", lines = results})
end

local function on_read(err, data)
    assert(not err, err)

    if data then
        local lines = vim.split(data, "\n")
        for index, line in ipairs(lines) do
            if index == #lines and line == "" then goto continue end

            table.insert(results, line)

            ::continue::
        end
    end
end

local function quickfix(cmd)
    local loop = vim.loop

    local args = vim.split(cmd, " ")
    cmd = table.remove(args, 1)

    stdout = loop.new_pipe()
    stderr = loop.new_pipe()

    handle = loop.spawn(cmd, {
        stdio = {nil, stdout, stderr},
        args = args
    }, vim.schedule_wrap(on_exit))

    loop.read_start(stdout, on_read)
    loop.read_start(stderr, on_read)
end

return quickfix
