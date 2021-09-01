local Language = {}

function Language:new(args)
    local state = {
        name = args.name,
        command = args.command,
        method = nil
    }

    self.__index = self
    return setmetatable(state, self)
end

function Language:setup(M, args)
    self.method = M.method
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

    if command then
        self.method(command)
    end
end

return Language
