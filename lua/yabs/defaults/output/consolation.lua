local function consolation(cmd)
    require("consolation").send_command {cmd = cmd}
end

return consolation
