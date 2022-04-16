local yabs = require("yabs.core")

require("yabs-plenary").setup()
require("yabs.defaults").setup()

yabs.run_command("echo hello, world", "plenary", {"quickfix", open_on_run = "never"})
