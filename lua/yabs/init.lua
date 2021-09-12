vim.cmd("augroup yabs")
vim.cmd("au!")
vim.cmd("au BufRead,BufNewFile .yabs set ft=lua")
vim.cmd("augroup end")

local Yabs = {
    default_output = nil,
    languages = {},
    tasks = {},
    default_language = nil,
    override_language = nil,
    did_config = false,
    did_setup = false
}

Yabs.Language = require("yabs/language")

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

function Yabs:run_task(task)
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
        self.override_language:run_task(task)
        return
    end

    local ft = vim.bo.ft
    local current_language = self.languages[ft]
    -- If the current filetype has a build command set up, run it
    if current_language then
        current_language:run_task(task)
    -- Otherwise, if there is a default_language set up, run its build command
    elseif self.default_language then
        self.default_language:run_task(task)
    end
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

    local ft = vim.bo.ft
    local current_language = self.languages[ft]
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
