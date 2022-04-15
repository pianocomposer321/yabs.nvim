local M = {}

--[[
M.register_selector("filetype", Filetype)

M.reigster_task("build", { runner = "plenary", output = "quickfix" })
M.register_task("run", { depends_on = "build", runner = { "terminal", height = 13 } })

M.register_placeholder("file", function() end)

M.add_tasks {
  build = {
    filetype = {
      "c" = "gcc #{FILE} -o #{FILE_NOEXT}",
      "cpp" = "g++ #{FILE} -o #{FILE_NOEXT}"
    }
  },
  run = {
    filetype = {
      python = "python3 #{FILE}",
      ["c,cpp"] = {"./#{FILE_NOEXT}", depends_on = "build", output = {"terminal", height = 13}}
    }
  }
}

M.add_task_group("build", {
  filetype = {
    c = "gcc ...",
    cpp = "g++ ..."
  }
})

M.add_task_group("run", {
  filetype = {
    c = "./main",
    cpp = "./main"
  }
}, { depends_on = "build" })

M.run_task("run")
M.run_task("run", "filetype")
M.run_task("run", "filetype.python")
M.run_task("run", nil, { output = "quickfix })
]]

local Selector = require("yabs.tasks.selector")
local s_instances = Selector.__instances

function M.register_selector(name, selector)
  s_instances[name] = selector
end

function M.add_task_group(group_name, group, opts)
  for selector_name, selector_tasks in pairs(group) do
    assert(s_instances[selector_name], "yabs: no selector named " .. selector_name)
    P(selector_name)
    P(selector_tasks)
  end
end

function M.run_task(task_type)
  error("yabs: run_task not implemented yet")
end

function M.debug()
  require("yabs.tasks.tests")
end

return M
