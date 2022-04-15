local yabs_tasks = require("yabs.tasks")

yabs_tasks.register_selector("filetype", {})

yabs_tasks.add_task_group("build", {
  filetype = {
    cpp = "g++ main.c -o main"
  }
})

-- yabs_tasks.run_task("run")
-- yabs_tasks.run_task("run", "filetype")
-- yabs_tasks.run_task("run", "filetype.python")
-- yabs_tasks.run_task("run", nil, { output = "quickfix })
