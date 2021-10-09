local Output = { }

function Output:new(func, config)
    local state = {
        func = func,
        config = config or {}
    }

    self.__index = self
    return setmetatable(state, self)
end

function Output:run(cmd, opts)
    opts = vim.tbl_extend("force", self.config, opts or {})
    self.func(cmd, opts)
end

return Output
