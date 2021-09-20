vim.cmd("augroup yabs")
vim.cmd("au!")
vim.cmd("au BufRead,BufNewFile .yabs set ft=lua")
vim.cmd("augroup end")

local Yabs = {
    default_output = nil,
    languages = {},
    tasks = {},
    type = "shell",
    output = "echo",
    default_language = nil,
    override_language = nil,
    did_config = false,
    did_setup = false,
}

Yabs.Language = require("yabs/language")
local Task = require("yabs.task")
local scopes = Task.scopes

function Yabs.run_command(...)
    require("yabs.util").run_command(...)
end

function Yabs:setup(opts)
    opts = opts or {}

    require("yabs.config").output_types = opts.output_types or {}

    local defaults = require("yabs/defaults")

    self.default_output = defaults.output_types[opts.default_output]  -- self.default_output equals the default_output config option
        or self.default_output                                        -- or iteslf if it's been set alread
        or defaults.default_output                                    -- or fallback to the default value

    self.default_type = opts.default_type  -- Pretty much the same thing here
        or self.default_type
        or defaults.default_type

    -- Add all the languages
    for name, options in pairs(opts.languages) do
        self:add_language(name, options)
    end

    -- Add tasks
    local tasks = opts.tasks or {}
    for name, options in pairs(tasks) do
        self:add_task(name, options)
    end

    self.did_setup = true
end

function Yabs:add_language(name, args)
    -- Creat a new language with `args` and call setup on it
    args.name = name
    local language = Yabs.Language:new(args)
    language:setup(self, {
        override = args.override,
        default = args.default
    })
end

function Yabs:get_current_language()
    local ft = vim.bo.ft
    return self.languages[ft]
end

function Yabs:add_task(name, args)
    args.name = name
    local task = Task:new(args)
    task:setup(self)
end

function Yabs:get_current_language_tasks()
    if not self.did_setup then return {} end
    return self:get_current_language().tasks
end

function Yabs:get_global_tasks()
    return self.tasks
end

function Yabs:get_tasks(scope)
    local local_tasks, global_tasks = self:get_current_language_tasks(), self:get_global_tasks()
    if scope then
        if scope == scopes.GLOBAL then
            return local_tasks
        end
        if scope == scopes.LOCAL then
            return global_tasks
        end
    end
    local tasks = vim.tbl_extend("keep", local_tasks, global_tasks)
    return tasks
end

function Yabs:run_global_task(task)
    if self.tasks[task] then
        self.tasks[task]:run()
    end
end

function Yabs:run_task(task, scope)
    -- local scopes = require("yabs.task").scopes

    local current_language = self:get_current_language()

    -- If we haven't loaded the .yabs config file yet, load it (if it doesn't
    -- exist, this will fail silently)
    if not self.did_config then
        self:load_config_file()
    end
    -- If we haven't run the setup function yet, run it
    if not self.did_setup then
        self:setup()
    end

    if scope == scopes.GLOBAL then
        self:run_global_task(task)
        return
    end
    if scope == scopes.LOCAL then
        -- If the current filetype has a build command set up, run it
        if current_language and current_language:has_task(task) then
            current_language:run_task(task)
        end
        return
    end

    -- If there is an override_language, run its build function and exit
    if self.override_language and self.override_language:has_task(task) then
        self.override_language:run_task(task)
        return
    end

    -- If the current filetype has a build command set up, run it
    if current_language and current_language:has_task(task) then
        current_language:run_task(task)
        return
    end
    -- Otherwise, if there is a default_language set up, run its build command
    if self.default_language and self.default_language:has_task(task) then
        self.default_language:run_task(task)
        return
    end
    if self.tasks then
        self:run_global_task(task)
        return
    end

    error("no task named " .. task)
end

function Yabs:run_default_task()
    -- If we haven't loaded the .yabs config file yet, load it (if it doesn't
    -- exist, this will fail silently)
    if not self.did_config then
        self:load_config_file()
    end
    -- If we haven't run the setup function yet, run it
    if not self.did_setup then
        self:setup()
    end

    -- If there is an override_language, run its build function and exit
    if self.override_language then
        -- self.override_language:build()
        self.override_language:run_default_task()
        return
    end

    local current_language = self:get_current_language()
    -- If the current filetype has a build command set up, run it
    if current_language then
        -- current_language:build()
        current_language:run_default_task()
    -- Otherwise, if there is a default_language set up, run its build command
    elseif self.default_language then
        -- self.default_language:build()
        self.default_language:run_default_task()
    end
end

local function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function Yabs:load_config_file()
    if file_exists(".yabs") then
        vim.cmd("luafile .yabs")
        self.did_config = true
        return true
    else
        self.did_config = true
        return false
    end
end

return Yabs
