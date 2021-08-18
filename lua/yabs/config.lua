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
    build_func = function(cmd)
        vim.cmd("bot 13new")
        vim.fn.termopen(cmd)
        vim.cmd("starti")
    end
}

return defaults
