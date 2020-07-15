local _M = {}
_M.top_vars = {}
_M.top_tbls = {}
_M.top_funs = {}

function _M.get_top_changes()
    local top_changed = {}
    for k,v in pairs(_G) do
        local type_v = type(v)
        if type_v == "string" or type_v == "number" or type_v == "boolean" or type_v == "nil" then
            local name = tostring(k)
            if _M.top_vars[name] == nil then
                _M.top_vars[name] = true
                top_changed[name] = 'variable:'..tostring(type_v)
            end
        elseif type_v == "function" then
            local name = tostring(k)
            if _M.top_funs[name] == nil then
                _M.top_funs[name] = true
                top_changed[name] = 'function:'..tostring(type_v)
            end
        elseif type_v == "userdata" or type_v == "thread" or type_v == "table" then
            local name = tostring(k)
            if _M.top_tbls[name] == nil then
                _M.top_tbls[name] = true
                top_changed[name] = 'object:'..tostring(type_v)
            end
        end
    end
    return top_changed
end

function _M.get_runtime_env(tbl, prefix, recur)
    local msg = ""
    for k,v in pairs(tbl) do
        local str_prefix = prefix .. "."
        str_prefix = string.gsub(str_prefix,"^_G.", "")

        local type_v = type(v)
        if type_v == "string" then
            msg = msg..string.format("%s = %s", str_prefix .. k, "\""..v.."\"").."\n"
        end
        if type_v == "number" or type_v == "boolean" or type_v == "nil" then
            msg = msg..string.format("%s = %s", str_prefix .. k, tostring(v)).."\n"
        end
        if type_v == "function" then
            local xi = debug.getinfo(v)
            msg = msg..str_prefix .. tostring(k).." "..tostring(xi.short_src).."."..tostring(xi.func).."\n"
        end
        if type_v == "userdata" or type_v == "thread" then
            msg = msg..str_prefix .. tostring(k).." type:"..type_v.."\n"
        end
        if type_v == "table" then
            if k == "_G" or k == "_G._G" then
                msg = msg..str_prefix..k.." ...(forced stop: _G)...\n"
            elseif k == "__index" then
                msg =  msg..str_prefix..k.." ...(forced stop: __index)...\n"
            else
                local recur_next = true
                if v.package then
                    recur_next = false
                end

                msg = msg..str_prefix .. k.."\n"

                local new_str_prefix = "    "..str_prefix .. k
                if string.len(new_str_prefix) >= 128 then
                    msg = msg.." ...(forced stop: too_long_to_show_1)...\n"
                else
                    if recur then
                        msg = msg.._M.get_runtime_env(v, new_str_prefix, recur_next).."\n"
                    end
                end
            end
        end
    end
    if string.len(msg) >= 32*1024 then
        msg = "...(forced stop: too_long_to_show_2)..."  --luacheck: ignore
    end
    return msg
end

function _M.get_runtime_env_top_dicts(vars, funs, exts)
    local msg = ""  --luacheck: ignore
    for k,v in pairs(_G) do
        local type_v = type(v)
        if type_v == "string" then
            msg = string.format("%s = %s", tostring(k), "\""..v.."\"")
            vars[tostring(k)] = msg
        elseif type_v == "number" or type_v == "boolean" or type_v == "nil" then
            msg = string.format("%s = %s", tostring(k), tostring(v))
            vars[tostring(k)] = msg
        elseif type_v == "function" then
            local xi = debug.getinfo(v)
            msg = tostring(k).." "..tostring(xi.short_src).."."..tostring(xi.func)
            funs[tostring(k)] = msg
        elseif type_v == "userdata" or type_v == "thread" then
            msg = tostring(k).." type: "..type_v
            exts[tostring(k)] = msg
        elseif type_v == "table" then
            if k == "_G" or k == "_G._G" then
                msg = tostring(k).."  type: table ...(forced stop: _G)..."
            elseif k == "__index" then
                msg =  tostring(k).." type: table ...(forced stop: __index)..."
            else
                msg = tostring(k).." type:"..type_v
            end
            exts[tostring(k)] = msg
        else
            msg = tostring(k).." type:"..tostring(type_v)
            exts[tostring(k)] = msg
        end
    end
end

function _M.get_runtime_env_top()
    local vars = {}
    local funs = {}
    local exts = {}

    _M.get_runtime_env_top_dicts(vars,funs,exts)

    local msgx = ""
    msgx = msgx.."Top functions:\n"
    for _,v in pairs(funs) do
        msgx = msgx .. "  ".. tostring(v).."\n"
    end
    msgx = msgx.."Top variables:\n"
    for _,v in pairs(vars) do
        msgx = msgx .. "  ".. tostring(v).."\n"
    end
    msgx = msgx.."Top others(table,userdata,thread...):\n"
    for _,v in pairs(exts) do
        msgx = msgx .. "  ".. tostring(v).."\n"
    end
    return msgx
end

return _M