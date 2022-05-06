# TODO: write proper documentation :^)

This is not meant to be full documentation for yabs. It is only meant to be a guide for people who want to test out the rewrite before it becomes the default version. If you have specific issues or questions, feel free to open an issue for now, and I will be sure to answer as best I can!

### `yabs.run_command(command: string | table, runner: string | table, output: string | table)`

Command: string or table containing command to run and arguments to pass to it
 - `"echo hi"`
 - `{"bash", "-c", "echo hi"}`

Runner: the name of the runner to use, with config parameters optionally passed
as other arguments to table
 - `"plenary"`
 - `"terminal"`
 - `{"terminal", direction = "vert"}`

Output: the name of the output to use, with config parameters optionally passed
as other arguments to table
 - `"buffer"`
 - `"quickfix"`
 - `{"quickfix", open_on_run = "never"}`

Examples:

```lua
require("yabs").run_command("python3 main.py", "terminal")
require("yabs").run_command("gcc main.c -o main", "plenary", {"quickfix", open_on_run = "never" })
```


### `yabs.run_commands(args: table)`

Run commands one after another. Args is a table of arguments to pass to
`yabs.run_command()`. Commands will be run in the order they are passed in the
`args` table. WARNING: Not all runners support chaining commands this way.

Examples:

```lua
require("yabs").run_commands {
  {"gcc main.c -o main", "plenary", "quickfix"},
  {"./main", "terminal}
}
```

### `yabs.tasks.add_tasks(tasks: table)`

Tasks: list of config options for tasks to add

Examples:

```lua
require("yabs.tasks").add_tasks { {
  type = "run",
  command = "echo running",
  runner = "plenary",
  output = "quickfix",
  active = true
}, {
  type = "build",
  command = {"echo", "building"},
  runner = "terminal",
  active = function()
    return true
  end
} }
```

### `yabs.tasks.run_task(args: table)`

Run first task with params matching those in `args`.

Examples:

```lua
require("yabs.tasks").run_task { type = "run" }
require("yabs.tasks").run_task { runner = "terminal" }
```

### `yabs.tasks.get_active_tasks()`

Get active tasks
