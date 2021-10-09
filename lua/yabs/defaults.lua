local outputs = require("yabs.outputs")

local defaults = {
    opts = {
        output_types = {
            quickfix = {
                open_on_run = "auto"
            }
        }
    },
    default_type = "shell",
    default_output = "echo",
}

return defaults
