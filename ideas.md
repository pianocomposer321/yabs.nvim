# Examples/Brainstorming

- languages (table): languages in vim 'filetype' format
  - lua, c (table): languages
    - actions (table): commands associated with that language
      - build, run, etc (string, function() -> string?): the actions
      - __outputs (table): the outputs for each action
        - (string, table, function(cmd: string, args: table))
        - Maybe have a "*" denote default for all not listed?
    - outputs (table): functions that get passed the value of an action
      and any args whose job it is to run that command
      - (function(cmd: string, args: table))
    - placeholders (table): key is text to be replaced, value is function returning
      string to replace it (or string to do a static string, though that may
      not be useful)
      - (string: function -> string)

## Defaults

Defaults should use metatables with __index.

#### Outputs
 - quickfix
 - terminal (run in shell, or command directly?)
 - ex (to run vim commands, just link directly to vim.cmd [or vim.api.nvim_command?])
 - echo (to run with :!)

What to do if there is no output? Probably fall back to default...maybe just
not send to any output, which would allow user to just run a lua function
instead...if not, maybe do this a different way? Maybe with lua output...

No, probably just set output to "" if you don't want it run. And provide lua function.

#### Actions
 - source (:source file ex command)

#### Placeholders
 - file (expand("%"))
 - file_noext (expand("%:r"))
 - file_ext (expand("%:e"))
 - expand (expand("%:" + args))

With telescope extension, maybe have a placeholder that gets replaced with text
returned from telescope picker.

Maybe without extension, similar one with vim.select menu (which can be
telescope or something else).

## Replicate example config for old yabs

```lua
require("yabs").setup {
  languages = {
    lua = {
      actions = {
        run = "luafile %",
        __outputs = {
          run = "ex"
        }
      }
    },
    c = {
      actions = {
        build = "gcc main.c -o main",
        run = "./main",
        __outputs = {
          build = {"quickfix", open_on_run = "always"},
          run = "terminal"
        }
      }
    }
  },
  actions = {
    build = "echo building project...",
    run = "echo running project...",
    optional = "echo runs on condition", -- TODO: THIS
    __outputs = {
      build = "terminal",
      run = "echo"
    }
  },
  __outputs = {
    {"quickfix", open_on_run = "always"}
  }
}
```

```lua
require("yabs").setup {
  languages = {
    lua = {
      actions = {
        run = "luafile %",
        __outputs = {
          run = "ex"
        }
      }
    },
    c = {
      actions = {
        build = "gcc main.c -o main",
        run = "./main",
        __outputs = {
          build = {"quickfix", open_on_run = "always"},
          run = "terminal"
        }
      }
    }
  }
}
```

## Extensions

Extensions should be able to add outputs, actions, etc. TODO: Checkout how Telescope (and cmp) do this.

## Chaining

This should be handled by an extension which adds a "chained" output. Will
figure out more for this later.

Maybe using TCP sockets and server? (with vim.loop as client and python as server)

```lua
require("yabs").setup {
  languages = {
    c = {
      actions = {
        build = "gcc main.c -o main",
        run = "./main",
        build_and_run = "",
        __outputs = {
          build_and_run = {
            "chained",
            actions = {"build", "run"},
            outputs = {"quickfix", "terminal"}
          }
        }
      }
    }
  }
}
```

```lua
require("yabs").setup {
  languages = {
    cpp = {
      actions = {
        build = "g++ #{FILE} -o #{FILE_NOEXT},
        run = "./#{FILE_NOEXT}",
        other = "echo 'doing some stuff'",
        __outputs = {
          build = "quickfix",
          run = "terminal",
          other = "custom"
        },
      },
      outputs = {
        custom = function(cmd, args)
          -- ...
        end
      }
    }
  },
  placeholders = {
    file = function()
      return vim.fn.expand("%")
    end,
    file_noext = function()
      return vim.fn.expand("%:r")
    end,
    file_ext = function()
      return vim.fn.expand("%:e")
    end,
    expand = function(args)
      return vim.fn.expand("%:" .. args[0])
    end
  },
  actions = {
    source = "source #{FILE}",
    __outputs = {
      source = ex
    }
  }
  outputs = {
    quickfix = function(cmd, args)
      -- ...
    end
    ex = vim.cmd,
    echo = function(cmd)
      vim.cmd("!" .. cmd)
    end
  }
}
```

```sh
python3 #{FILE}
```

```sh
g++ #{FILE} -o #{FILE_NOEXT}
```

```sh
echo #{EXPAND:t}
```
