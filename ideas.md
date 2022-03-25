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

## Chaining

```lua
require("yabs").setup {
  languages = {
    c = {
      actions = {
        build = "gcc main.c -o main",
        run = "./main",
        build_and_run = "",
        __outputs = {
          build_and_run = {"chained", actions = {"build", "run"}, outputs = {"quickfix", "terminal"}}
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
    ex = vim.cmd
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
