local Type = {}

function Type:new(runner, output)
  return setmetatable({ runner = runner, output = output, groups = {} }, { __index = self })
end

function Type:add_group(group)
  table.insert(self.groups, 1, group)
end

function Type:run_task(selector_name, selection)
  for _, group in ipairs(self.groups) do
    if selector_name and group.selector.name ~= selector_name then
      goto continue
    end

    local task = group.selector:make_selection(group.tasks)
    task:run()

    ::continue::
  end
end

return Type
