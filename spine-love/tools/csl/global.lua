local _M = {}

local function _is_tool_func(name)
    if name == "inspect" or name == "dbg" or name == "console" then
        return true
    end
    return false
end

function _M.list_global(mode)
    print("list_global mode: "..tostring(mode))
    local funs = {}
    local tbls = {}
    local oths = {}
    for k, v in pairs(_G) do
        if type(v) == "table" or type(v) == "rotable" then
            table.insert(tbls, k)
        elseif type(v) == "function" then
            table.insert(funs, k)
        else
            table.insert(oths, k)
        end
    end
    if mode == "all" or mode == "function" or mode == "functions" then
        print("functions:")
        table.sort(funs)
        for _, k in ipairs(funs) do
            if _is_tool_func(k) then
                print("   "..k.." *")
            else
                print("   "..k)
            end
        end
    end
    if mode == "all" or mode == "other" or mode == "others" then
        print("others:")
        table.sort(oths)
        for _, k in ipairs(oths) do
            print("   "..k)
        end
    end
end


return _M