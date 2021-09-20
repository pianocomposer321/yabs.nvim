local telescope = require('telescope')
local actions = require('telescope.actions')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local Yabs = require('yabs')
local scopes = require('yabs.task').scopes

local function select_task(opts, scope)
  pickers.new(opts, {
    prompt_title = 'Select a task',
    finder = finders.new_table({
      results = vim.tbl_values(Yabs:get_tasks(scope)),
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
          Yabs:run_task(entry.value, scope)
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
      select_task(opts)
    end,
    current_language_tasks = function(opts)
      select_task(opts, scopes.LOCAL)
    end,
    global_tasks = function(opts)
      select_task(opts, scopes.GLOBAL)
    end,
  },
})
