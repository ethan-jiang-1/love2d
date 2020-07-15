local _M = {}

function _M.load_app_module(modname)
    print("loading following to console in global:"..tostring(modname))

    local mod = require(modname)
    if mod ~= nil then
        local sys_string = require("utils.sys_string")
        local list = sys_string.split(modname, ".")
        local name = list[#list]

        _G[name] = mod
        print("  "..tostring(name).. " = require('"..tostring(modname).."')")
        if type(mod.init) == "function" then
            mod.init()
        end
        return true
    end
    return false
end

return _M