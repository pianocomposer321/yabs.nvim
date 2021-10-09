vim.cmd("augroup yabs")
vim.cmd("au!")
vim.cmd("au BufRead,BufNewFile .yabs set ft=lua")
vim.cmd("augroup end")

local Yabs = {
    default_output = nil,
    default_type = nil,
    languages = {},
    tasks = {},
}

local did_config = false
local did_setup = false

Yabs.Language = require("yabs.language")
local Task = require("yabs.task")
local scopes = Task.scopes

function Yabs.run_command(...)
    require("yabs.util").run_command(...)
end

local function _set_output_type_configs(output_types)
    for output_type, config in pairs(output_types) do
        require("yabs.outputs")[output_type].config = config
    end
end

function Yabs:setup(config)
    local defaults = require("yabs.defaults")
    config = vim.tbl_deep_extend('force', defaults, config or {})

    _set_output_type_configs(config.opts.output_types)

    -- defaults.opts = opts
    -- opts = opts or {}

    local outputs = require("yabs.outputs")
    self.default_output = outputs[config.default_output]
        or self.default_output
        or defaults.output

    self.default_type = config.default_type
        or self.default_type
        or defaults.default_type

    -- Add all the languages
    config.languages = config.languages or {}
    for name, options in pairs(config.languages) do
        self:add_language(name, options)
    end

    -- Add tasks
    local tasks = config.tasks or {}
    for name, options in pairs(tasks) do
        self:add_task(name, options)
    end

    did_setup = true
end

function Yabs:add_language(name, args)
    -- Creat a new language with `args` and call setup on it
    args.name = name
    args = vim.tbl_extend("force", {output = self.default_output, type = self.default_type}, args)
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
    args = vim.tbl_extend("force", {output = self.default_output, type = self.default_type}, args)
    local task = Task:new(args)
    task:setup(self)
end

function Yabs:get_current_language_tasks()
    if not did_setup then return {} end
    local cur_lang = self:get_current_language()
    if not cur_lang then return {} end
    return cur_lang.tasks
end

function Yabs:get_global_tasks()
    return self.tasks
end

function Yabs:get_tasks(scope)
    if not scope then scope = scopes.ALL end

    if scope == scopes.GLOBAL then
        return self:get_global_tasks()
    end
    if scope == scopes.LOCAL then
        return self:get_current_language_tasks()
    end

    assert(scope == scopes.ALL, "unsupported scope: " .. scope)
    return vim.tbl_extend("keep", self:get_current_language_tasks(), self:get_global_tasks())
end

function Yabs:run_global_task(task, opts)
    if self.tasks[task] then
        self.tasks[task]:run(opts)
    end
end

function Yabs:run_task(task, opts)
    if not opts then opts = {} end

    local current_language = self:get_current_language()

    -- If we haven't loaded the .yabs config file yet, load it (if it doesn't
    -- exist, this will fail silently)
    if not did_config then
        self:load_config_file()
    end
    -- If we haven't run the setup function yet, run it
    if not did_setup then
        self:setup()
    end

    local scope = opts.scope
    if not scope then scope = scopes.ALL end

    if scope == scopes.GLOBAL then
        self:run_global_task(task, opts)
        return
    end
    if scope == scopes.LOCAL then
        -- If the current filetype has a build command set up, run it
        if current_language and current_language:has_task(task) then
            current_language:run_task(task, opts)
        end
        return
    end
    assert(scope == scopes.ALL, "unsupported scope: " .. scope)

    -- If there is an override_language, run its build function and exit
    if self.override_language and self.override_language:has_task(task) then
        self.override_language:run_task(task)
        return
    end

    -- If the current filetype has a build command set up, run it
    if current_language and current_language:has_task(task) then
        current_language:run_task(task, opts)
        return
    end
    -- Otherwise, if there is a default_language set up, run its build command
    if self.default_language and self.default_language:has_task(task) then
        P("running default language task")
        self.default_language:run_task(task)
        return
    end
    if self.tasks and self.tasks[task] then
        self:run_global_task(task, opts)
        return
    end

    error("no task named " .. task)
end

function Yabs:run_default_task()
    -- If we haven't loaded the .yabs config file yet, load it (if it doesn't
    -- exist, this will fail silently)
    if not did_config then
        self:load_config_file()
    end
    -- If we haven't run the setup function yet, run it
    if not did_setup then
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
        current_language:run_default_task()
    -- Otherwise, if there is a default_language set up, run its build command
    elseif self.default_language then
        vim.notify(
            "yabs: deprecation notice: default languages are superceded by global tasks",
            vim.log.levels.WARN
        )
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
        dofile(vim.fn.getcwd() .. "/.yabs")
        did_config = true
        return true
    else
        did_config = true
        return false
    end
end

return Yabs
