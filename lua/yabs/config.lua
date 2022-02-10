local config = {
  defaults = {
    opts = {
      output_types = {
        quickfix = {
          open_on_run = 'auto',
        },
      },
    },
    type = 'shell',
    output = 'echo',
  },
  exec_untrusted = false,
}
setmetatable(config, { __index = config.defaults })

return config
