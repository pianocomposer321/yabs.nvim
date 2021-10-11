# yabs.nvim

Yet Another Build System for Neovim, written in lua.

<!-- ![screenshot](./screenshot.png) -->

## About

At its heart, yabs.nvim is just a mapping of languages/filetypes to the command that will build and/or run them. You provide a string (or a function - more on that later) designating what command to run as well as a function that takes that string as an argument. Any time you run `require("yabs"):build()`, the plugin will pass the command for the current filetype to the build function.

## Installation
Packer.nvim:

`use 'pianocomposer321/yabs.nvim'`

vim-plug:

`Plug 'pianocomposer321/yabs.nvim'`

etc.

## Setup

```lua
require("yabs"):setup {
    languages = {  -- List of languages in vim `filetype` format
        lua = {
            tasks = {
                run = {
                    command = "luafile %",  -- The cammand to run (% and other
                                            -- wildcards will be automatically
                                            -- expanded)
                    type = "vim"  -- The type of command (can be `vim`, `lua`, or
                                  -- `shell`, default `shell`)
                }
            }
        },
        c = {
            default_task = "build_and_run",
            tasks = {
                build = {
                    command = "gcc main.c -o main",
                    output = "quickfix",  -- Where to show output of the
                                          -- command can be `buffer`,
                                          -- `consolation`, `echo`,
                                          -- `quickfix`, `terminal`, or `none`
                    opts = {  -- Options for output (currently, the only one
                              -- is `open_on_run`, which defines the behavior
                              -- for the quickfix list opening) (can be
                              -- `never`, `always`, or `auto`, the default)
                        open_on_run = "always"
                    }
                },
                run = {  -- You can specify as many tasks as you want per
                         -- filetype
                    command = "./main",
                    output = "consolation"
                },
                build_and_run = {  -- Setting the type to lua means the command
                                   -- is a lua function
                    command = function()
                        -- The following api can be used to run a task when a
                        -- previous one finishes
                        -- WARNING: this api is experimental and subject to
                        -- changes
                        require("yabs"):run_task("build", {on_exit = function()
                            require("yabs").languages.c:run_task("run")
                        end})
                    end,
                    type = "lua"
                }
            }
        }
    },
    tasks = {  -- Same values as `language.tasks`, but global
        build = {
            command = "echo building project...",
            output = "consolation"
        },
        run = {
            command = "echo running project..",
            output = "echo"
        }
    },
    opts = {  -- Same values as `language.opts`
        output_types = {
            quickfix = {
                open_on_run = "always"
            }
        }
    }
}
```

## Usage

```lua
local yabs = require("yabs")

-- runs the task `build` for the current language, falling back to a global
-- task with that name if it is not found for the current language
yabs:run_task("build")  

-- runs the tasks that is specified as the default (see configuration section
-- above), or the first one if not specified
yabs:run_default_task()

-- Run command `echo hello, world` directly. Output is specified by the second
-- argument (same possible values as `output` option for tasks above), and
-- additional arguments are spcified with the third argument (same as
-- `task.opts` above)
yabs.run_command("echo hello, world", "quickfix", {open_on_run = "always"})
```

### ".yabs" files

The first time you run `yabs:build()`, yabs will look for a file named .yabs in
the current working directory. If found, it will be sourced as a lua file. This
is useful for project-local configurations.

## Telescope integration

You can execute tasks from Telescope by running `:Telescope yabs tasks` / `:Telescope yabs current_language_tasks` or `:Telescope yabs global_tasks`.

## Advanced configuration

The `language.command` option in `yabs:setup()` can be a string or a function that returns a string. Specifying a function instead can be useful for more advanced commands.

Likewise, the `language.output` option can be one of the included types (`buffer`, `consolation`, `echo`, `quickfix`, `terminal`, or `none`), or a function accepting one argumet - the command to run. For example, if you are using tmux, you could write a function to send the command to a tmux pane.

### Chaining tasks

You can set a task to run when a previous one finishes by setting the `on_exit`
value of the `opts` table in `yabs:run_task()`. This api is experimental and
subject to change, and is not recommended to be used in normal configurations.

## Screenshots

<details>
<summary>Buffer</summary>

![buffer](./buffer.png)
</details>

<details>
<summary>Echo</summary>

![echo](./echo.png)
</details>

<details>
<summary>Quickfix</summary>

![quickfix](./quickfix.png)
</details>

<details>
<summary>Terminal</summary>

![termina](./terminal.png)
</details>
<!-- ![screenshot](./screenshot.png) -->
