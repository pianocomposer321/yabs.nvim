--[[ local U = {}

local O = {
    -- build_func = function(cmd) vim.cmd("!"..cmd) end
    build_func = function(cmd)
        vim.cmd("bot 13new")
        vim.fn.termopen(cmd)
        vim.cmd("starti")
    end
}

function U.create_config(opts)
    if not opts then
        return O
    end

    return {
        build_func = opts.build_func or O.build_func
    }
end

return U ]]

local defaults = {
    method = nil
}

function defaults.termopen(cmd)
    vim.cmd("bot 13new")
    vim.fn.termopen(cmd)
    vim.cmd("starti")
end

function defaults.quickfix(cmd)
end

defaults.method = defaults.termopen

return defaults
