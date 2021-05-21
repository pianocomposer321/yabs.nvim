# yabs.nvim

Yet Another Build System for Neovim, written in lua

![screenshot](./screenshot.png)

## About

At its heart, yabs.nvim is just a mapping of languages/filetypes to the command that will build and/or run them. You provide a string (or a function - more on that later) designating what command to run as well as a function that takes that string as an argument. Any time you run `Yabs:build()`, the plugin will pass the command for the current filetype to the build function.

## Usage
Yabs has two objects that you will interact with when using the plugin: `Yabs`, the main plugin object, and `Language`, which represents a filetype and contains the values used to build files of that type.

### Yabs

#### `Yabs:setup(opts)`
Setup the plugin using provided configuration options.

##### Arguments

- `build_func`: A function accepting the build command as an argument. Called by `Yabs:build()`.
<details>
<summary>Default</summary>

```lua
function(cmd)
    vim.cmd("bot 13new")
    vim.fn.termopen(cmd)
    vim.cmd("starti")
end
```
</details>

#### `Yabs:build()`
Run the build command for the current filetype.

### Language

#### `Language:new(args)`
Create a new language object.

##### Arguments

- `name`: The name of the language. This is the value that will be used by `Yabs:build()` to determine what command to run for the open file, and so it should be in vim `'filetype'` format, e.g. for "\*.py" files it should be "python", for "\*.lua" files it should be "lua", etc.
- `command`: This argument determines what command will be run by `Yabs:build()` for the filetype designated by the value of `name`. It can be a literal string or a function that returns a string. If it is a function and it returns no value, `Yabs:build()` will simply exit gracefully. This allows you to do things for specific filetypes other than run a shell command, like for lua files running the neovim command `:luafile %` for example.

#### `Language:setup(M, args)`
Register the language in the `Yabs` object's internal list of languages, and setup a few advanced configuration options.

##### Arguments

- `M`: A reference to the Yabs object
- `args`: An optional argument containing a table which controls special values for the `Language` object. Their values are as follows:

- `default`: Boolean value which determines whether this language is to be the "default" language, i.e. the one that is run for filetypes without their own `Language` object. If this is `true`, the `Language` object's `name` variable is ignored, and can be set to anything (like "default" for example).
- `override`: Boolean value which determines whether this language is to be the "override" language. If this value is true, all other `Language` objects are ignored, and this object's `command` is always run, no matter the filetype. Like the `defaulte` option, if this value is set, this object's `name` is ignored.

## The ".yabs" file
Yabs.vim will look for a file called ".yabs" in the root of your project once per neovim session the first time you run `Yabs:build()`. If it is found, it will be sourced as a lua file. This can be used for per-project configuration.

## Examples

### Run using !cmd syntax
```lua
Yabs = require("yabs")
Yabs:setup {
    build_func = function(cmd) vim.cmd("!"..cmd) end
}

local Language = Yabs.Language

local python = Language:new {
    name = "python",
    command = function()
        -- Returns "python3" plus the name of the current file
        local file = vim.fn.expand("%:~:.")
        return "python3 "..file
    end
}
python:setup(Yabs)

local lua = Language:new {
    name = "lue",
    command = function()
        -- This function doesn't return anything, so no shell commands will be run
        vim.cmd("luafile %")
    end
}
lua:setup(Yabs, {default = true})
```

### Run using [consolation.nvim](https://github.com/pianocomposer321/consolation.nvim)
```lua
local Wrapper = require("consolation").Wrapper

TerminalWrapper = Wrapper:new()
TerminalWrapper:setup {
    -- snip
}

Yabs = require("yabs")
Yabs:setup {
    build_func = function(cmd)
        TerminalWrapper:send_command {cmd = cmd}
    end
}

-- snip: rest is same as above
```
