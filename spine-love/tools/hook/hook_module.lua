local _M = {}

function _M.newhook_tick(func, name)
    local hookedfunc = {}
    
    hookedfunc.__hooks = {}
    hookedfunc.__func = func
    hookedfunc.__tname = name
    hookedfunc.__callnum = 0
    hookedfunc.__maxsec = 0
    
    setmetatable(hookedfunc, {
        __call = function(func, ...) --luacheck:ignore
            local t0 = os.time()

            --print("hooked call "..tostring(hookedfunc.__tname))
            if _G.sys_log and _G.sys_log.record_last_lua_fname then
                if _G.thread and _G.thread.thread_id then
                    local  thread_id = _G.thread.thread_id()
                    _G.sys_log.record_last_lua_fname(thread_id, hookedfunc.__tname)
                end
            end
            
            local ret1, ret2, ret3, ret4, ret5 = hookedfunc.__func(...)

            local t1 = os.time()
            hookedfunc.__callnum = hookedfunc.__callnum + 1
            local tm_sec = t1 - t0
            if hookedfunc.__maxsec < tm_sec then
                hookedfunc.__maxsec = tm_sec
            end

            if ret5 then
                return ret1, ret2, ret3, ret4, ret5
            elseif ret4 then
                return ret1, ret2, ret3, ret4
            elseif ret3 then
                return ret1, ret2, ret3
            elseif ret2 then
                return ret1, ret2
            end
            return ret1
        end
    })
    
    return hookedfunc
end


function _M.hook_func_tick(func, name)
    return _M.newhook_tick(func, name)
end

function _M.hook_table_tick(tbl, tbl_name)
    if type(tbl) == "table" and type(tbl_name) == "string" then
        for key, value in pairs(tbl) do
            if type(value) == "function" then
                tbl[key] = _M.hook_func_tick(value, tbl_name.."."..key)
            end
        end
        print("table "..tostring(tbl_name).." hooked")
        return true
    end
    return false
end

function _M.hook_module_tick_by_name(module_name)
    if type(module_name) == "string" then
        local status, mod = pcall(require, module_name)
        if status then
            return _M.hook_table_tick(mod, module_name)
        end
    end
    print("failed to hook module: "..tostring(module_name))
    return false
end

function _M.hook_module_tick_in_global(tbl_in_g, tbl_name)
    if type(tbl_in_g) == "table" and type(tbl_name) == "string" then
        return _M.hook_table_tick(tbl_in_g, tbl_name)
    end
    print("failed to hook table: "..tostring(tbl_name))
    return false
end

return _M