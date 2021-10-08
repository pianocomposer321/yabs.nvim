local outputs = require("yabs.outputs")

local config = {
    opts = {
        output_types = {
            quickfix = {
                open_on_run = "auto"
            }
        }
    },
    default_type = "shell",
    default_output = outputs.echo,
}

return config
