local Language = {}

local output_types = require("yabs/defaults").output_types

function Language:new(args)
    local state = {
        name = args.name,
        command = args.command,
        type = args.type,
        output = args.output
    }

    self.__index = self
    return setmetatable(state, self)
end

function Language:setup(M, args)
    if not self.output then self.output = M.default_output end
    if not self.type then self.type = M.default_type end
    M.languages[self.name] = self

    if args then
        if args.default == true then
            M.default_language = self
        end
        if args.override == true then
            M.override_language = self
        end
    end
end

function Language:build()
    local command
    if type(self.command) == "function" then
        command = self.command()
    else
        command = self.command
    end

    local output
    if type(self.output) == "string" then
        output = output_types[self.output]
    elseif type(self.output) == "function" then
        output = self.output
    end

    if self.type == "vim" then
        vim.cmd(command)
    elseif self.type == "shell" then
        output(command)
    end
end

return Language
