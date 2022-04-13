local yabs = require("yabs")

require("yabs-plenary").setup()
require("yabs-defaults").setup()

yabs.run_commands {
  { {"bash", "-c", "echo start && sleep 2 && echo end"}, "plenary", "quickfix" },
  { {"bash", "-c", "echo hello, world"}, "plenary", "quickfix" },
  { {"bash", "-c", "echo hi"}, "system", { "echo", inspect = true } }
}
