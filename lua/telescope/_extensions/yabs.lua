local telescope = require('telescope')
local actions = require('telescope.actions')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local Yabs = require('yabs')

local function select_task(tasks_function, opts)
  pickers.new(opts, {
    prompt_title = 'Select a task',
    finder = finders.new_table({
      results = vim.tbl_values(tasks_function(Yabs)),
      entry_maker = function(entry)
        return {
          value = entry.name,
          display = string.format('%s: %s', entry.name, entry.command),
          ordinal = entry.name .. entry.command,
        }
      end,
    }),
    sorter = sorters.get_fzy_sorter(),
    attach_mappings = function(prompt_bufnr)
      local source_session = function()
        actions.close(prompt_bufnr)
        local entry = actions.get_selected_entry(prompt_bufnr)
        if entry then
          Yabs:run_task(entry.value, opts)
        end
      end

      actions.select_default:replace(source_session)
      return true
    end,
  }):find()
end

return telescope.register_extension({
  exports = {
    tasks = function(opts)
      select_task(Yabs.get_tasks, opts)
    end,
    current_language_tasks = function(opts)
      opts.current_language = true
      select_task(Yabs.get_current_language_tasks, opts)
    end,
    global_tasks = function(opts)
      opts.global = true
      select_task(Yabs.get_global_tasks, opts)
    end,
  },
})
