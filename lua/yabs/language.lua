local Language = {}

local Task = require("yabs.task")

local output_types = require("yabs.outputs")

function Language:new(args)
    local state = {
        name = args.name,
        -- command = args.command,
        tasks = args.tasks or {},
        default_task = args.default_task,
        type = args.type,
        output = args.output,
        opts = args.opts
    }

    self.__index = self
    return setmetatable(state, self)
end

function Language:setup(parent, args)
    if not self.output then self.output = parent.default_output end
    if not self.type then self.type = parent.default_type end

    for task, options in pairs(self.tasks) do
        self:add_task(task, options)
    end

    parent.languages[self.name] = self

    if args then
        if args.default == true then
            parent.default_language = self
        end
        if args.override == true then
            parent.override_language = self
        end
    end

    local tasks_keys = vim.tbl_keys(self.tasks)
    if not self.default_task and #tasks_keys > 0 then
        self.default_task = self.tasks[tasks_keys[1]].name
    end
end

function Language:add_task(name, args)
    args.name = name
    local task = Task:new(args)
    task:setup(self)
end

function Language:set_output(output)
    -- Set output of this language to output type `output`
    assert(type(output) == "string", "Type of output argument must be string!")
    output = output_types[output]
    self.output = output
    return output
end

function Language:has_task(task)
    if type(task) == "string" then
        return self.tasks[task] ~= nil
    end
    if type(task) == "table" then
        for _, subtask in pairs(task) do
            if not self:has_task(subtask) then
                return false
            end
        end
        return true
    end
    return false
end

function Language:run_task(task, opts)
    -- self.tasks[task]:run()
    assert(self:has_task(task), "invalid task " .. vim.inspect(task) .. " for language " .. self.name)
    if type(task) == "string" then
        self.tasks[task]:run(opts)
    elseif type(task) == "table" then
        -- TODO: Add error checking for each sequential command
        for _, subtask in pairs(task) do
            self.tasks[subtask]:run()
        end
    end
end

function Language:run_default_task()
    self:run_task(self.default_task)
end

return Language
