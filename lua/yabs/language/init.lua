local Language = {}

local output_types = require("yabs/defaults").output_types

function Language:new(args)
    local state = {
        name = args.name,
        command = args.command,
        type = args.type,
        output = args.output,
        opts = args.opts
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

function Language:set_output(output)
    -- Set output of this language to output type `output`
    assert(type(output) == "string", "Type of output argument must be string!")
    output = output_types[output]
    self.output = output
    return output
end

function Language:build()
    local command
    if type(self.command) == "function" then
        -- If `self.command` is a function, command is the result of it
        command = self.command()
    else
        command = self.command
    end

    command = require("yabs.util").expand(command)

    if self.type == "vim" then
        vim.cmd(command)
    elseif self.type == "shell" then
        -- output(command, self.opts)
        require("yabs.util").run_command(command, self.output)
    end
end

return Language
