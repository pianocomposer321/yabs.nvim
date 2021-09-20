local Task = {
    scopes = {
        GLOBAL = 1,
        LOCAL = 2
    }
}

function Task:new(args)
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

function Task:setup(parent)
    if not self.output then self.output = parent.output end
    if not self.type then self.type = parent.type end

    parent.tasks[self.name] = self
end

function Task:run()
    local command
    if type(self.command) == "function" then
        -- If `self.command` is a function, command is its return value
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

return Task
