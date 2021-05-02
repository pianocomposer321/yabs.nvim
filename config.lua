local U = {}

local O = {
    build_func = function(cmd) vim.cmd("!"..cmd) end
}

function U.create_config(opts)
    if not opts then
        return O
    end

    return {
        build_func = opts.build_func or O.build_func
    }
end

return U
