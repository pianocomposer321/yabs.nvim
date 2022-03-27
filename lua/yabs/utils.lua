return {
  split = function(str, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for substr in string.gmatch(str, "([^" .. sep .. "]+)") do
      table.insert(t, substr)
    end
    return t
  end
}
