require("yabs.defaults").setup()
require("yabs-plenary").setup()
local yabs_tasks = require("yabs.tasks")

local Filetype = require("yabs.tasks.selector"):new()
function Filetype:select()
  return vim.bo.ft
end
yabs_tasks.register_selector("filetype", Filetype)

yabs_tasks.add_type {
  "run",
  runner = "terminal"
}

yabs_tasks.add_tasks {
  type = "run",
  selector = {"filetype", key = "val" },
  tasks = {
    python = "python3 #{FILE}",
    lua = {
      "echo 'hi'",
      runner = "ex"
    },
    cpp = {
      "./#{FILE_NOEXT}",
      depends_on = "build",
      runner = "plenary"
    },
    c = {
      "./#{FILE_NOEXT}",
      depends_on = "build"
    }
  }
}

yabs_tasks.run_task("run", "filetype")

--[[
Group: run
 - tasks:
  - Task:
   - group_name: run
   - selector: filetype
   - id: python
   - command: python3 main.py
   - runner: terminal
  - Task:
   - group_name: run
   - selector: filetype
   - id: lua
   - command: luafile %
   - runner: func(vim.cmd)
  - Task:
   - group_name: run
   - selector: filetype
   - id: cpp
   - command: ./main
   - runner: terminal
   - depends_on: build
]]
