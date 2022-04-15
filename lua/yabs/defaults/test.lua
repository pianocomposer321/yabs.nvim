local yabs = R("yabs.core", true)

local Terminal = require("yabs.defaults.runners.terminal")
yabs.register_runner("terminal", Terminal)

yabs.run_command("echo hello", "terminal")

