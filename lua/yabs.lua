if not Debugging then Debugging = function() end end

local M = {}

local languages
local tasks
local outputs
local placeholders

M.setup = function(config)
  languages = config.languages or {}
  tasks = config.tasks or {}
  outputs = config.outputs or {}
  placeholders = config.placeholders or {}

  for key, language in pairs(languages) do
    if placeholders then
      languages[key].placeholders = setmetatable(language.placeholders or {},
        { __index = placeholders })
    end

    if tasks then
      languages[key].tasks = setmetatable(language.tasks or {}, { __index = tasks })
    end

    if outputs then
      languages[key].outputs = setmetatable(language.outputs or {}, { __index = outputs })
    end
  end
end

local get_output_name = function(language, task)
  return languages[language].tasks.__outputs[task]
end

local get_cur_lang = function()
  return vim.api.nvim_buf_get_option(0, "filetype")
end

M.run_task = function(task_name, args)
  local cur_lang_name = get_cur_lang()
  local cur_lang = languages[cur_lang_name]
  local command = cur_lang.tasks[task_name]
  local output_name = get_output_name(cur_lang_name, task_name)
  local output = cur_lang.outputs[output_name]
  output(command)
end

if Debugging() then
  M.setup {
    languages = {
      lua = {}
    },
    tasks = {
      say_hi = "echo 'hi'",
      __outputs = {
        say_hi = "echo"
      }
    },
    outputs = {
      echo = function(cmd, args)
        vim.cmd("!" .. cmd)
      end,
      cmd = vim.cmd
    }
  }

  M.run_task("say_hi")
end

return M
