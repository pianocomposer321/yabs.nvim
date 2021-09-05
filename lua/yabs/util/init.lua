local M = {}

local function on_exit(stdio, handle, on_exit_)
    local stdin, stdout, stderr = unpack(stdio)

    stdout:read_stop()
    stderr:read_stop()

    stdout:close()
    stderr:close()

    if stdin then stdin:shutdown() end

    handle:close()

    if on_exit_ then on_exit_() end
end

local function on_read(err, data, on_read_, split_lines)
    assert(not err, err)
    
    if not data then return end

    if split_lines then
        data = vim.split(data, "\n")
    end

    if on_read_ then on_read_(data) end
end

function M.async_command(cmd, opts)
    local default_opts = {
        use_stdin = false,
        dont_schedule = false,
        split_lines = true,
        on_exit = function() end,
        on_read = function(data) end
    }

    opts = vim.tbl_extend("keep", opts, default_opts)

    local loop = vim.loop

    local args = vim.split(cmd, " ")
    cmd = table.remove(args, 1)

    local stdout = loop.new_pipe()
    local stderr = loop.new_pipe()
    local stdin
    if opts.use_stdin then stdin = loop.new_pipe() end

    local stdio = {stdin, stdout, stderr}

    local handle
    if opts.dont_schedule then
        handle = loop.spawn(cmd, {
            stdio = stdio,
            args = args
        }, function() on_exit(stdio, handle, opts.on_exit) end)
    else
        handle = loop.spawn(cmd, {
            stdio = stdio,
            args = args
        }, vim.schedule_wrap(function() on_exit(stdio, handle, opts.on_exit) end))
    end

    local l_on_read = function(err, data) on_read(err, data, opts.on_read, opts.split_lines) end
    loop.read_start(stdout, l_on_read)
    loop.read_start(stderr, l_on_read)

    return handle, stdin
end

return M
