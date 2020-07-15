local _M = {}

_M.initialized = false
_M.require_queue = {}
_M.required_modules = {}


_M.log_path = nil

local function _get_root_loc_by_env()
    local loc = "/"
    if os.getenv("HOME") then
        local pwd = os.getenv("PWD")
        if pwd then
            local pos = string.find(pwd, '/app')
            if pos then
                loc = string.sub(pwd, 1, pos) -- anywhere under /app
            else
                pos = string.find(pwd, "/tests")
                if pos then
                    loc = string.sub(pwd, 1, pos) -- anywhere under /tests
                else
                    loc = pwd .."/"
                end
            end
        end
    end
    return loc
end

local function _get_ses_num()
    local sstbl =  _G.sys.get_device_info(_G.sys.DI_TYPE.SESSION)
    if sstbl and sstbl.session then
        return tonumber(sstbl.session)
    end
    return 0
end


local function _get_log_path()
    if _M.log_path == nil then
        local sn = math.floor(_get_ses_num()) % 20
        _M.log_path = _get_root_loc_by_env()..string.format("sdcard/log/fpt_%02d.log", sn)
        print("\n\n## footmem file: ".._M.log_path.."\n\n")
    end
    return _M.log_path
end

local function _log_to_file(msg)
    local log_path = _get_log_path()
    local fh = io.open(log_path, "a")
    if fh then
        if _M.log_start == nil then
            _M.log_start = true
            local dvs_info = _G.sys.get_device_info(0)
            fh:write("\n\n")
            if dvs_info then
                fh:write(dvs_info.PN_PLUTO_BORIS)
            end
            fh:write("\n\n")
        end
        fh:write(msg.."\n")
        fh:close()
    end
end    

local function size_ceil(n)
    return  math.ceil(n*1000)/1000
end

local function log_mem(msg)
    local ec = string.char(27)
    local BLUE =  ec.."[34m"
    local RESET = ec.."[0m"
    print(BLUE..tostring(msg)..RESET)
    pcall(_log_to_file, msg)
end

local function log_space(pad)
    if string.len(pad) <= 2 and _G.sys.get_space_mem_lua then
        local tt, used = _G.sys.get_space_mem_lua()
        local free = tt - used
        print(string.format("get_space_mem_lua (total/used/free): %.3f %.3f %.3f ", 
                            size_ceil(tt/1024), size_ceil(used/1024), size_ceil(free/1024)))
    end
end

------------------------
-- Core hooks
    --  require in system
local function fpt_check_memory_core(trace_mark, pad)
    collectgarbage("collect")
    local n0 =size_ceil(collectgarbage("count"))

    local msg
    if pad == nil then
        msg = string.format("memory usage %.3f K @ %s", n0, tostring(trace_mark))
        _M.log_mem(msg)
    else
        msg = string.format("%smemory usage %.3f K @ %s", pad, n0, tostring(trace_mark))
        _M.log_mem(msg)
    end
end

function _M.weakref(obj)
    local weak = setmetatable({ref=obj}, {__mode="v"})
    return function() return weak.ref end
end

function _M.check_memory(trace_mark, pad)
    pcall(fpt_check_memory_core,trace_mark,pad)
end

function _M.hijack_require(name)
    --print(_M.hijack_require, _G.require, _M.org_require)
    --print("call hijacked require: "..name)
    assert(_M.initialized)
    if _M.org_require ~= nil then
        --if _M.required_modules[name] then
        local ref = _M.required_modules[name]
        if ref == nil or ref() == nil then
            table.insert(_M.require_queue, name)
            local   tm = #(_M.require_queue)
            local pad = ""
            for i=2, tm do --luacheck: ignore
                pad = pad.."  "
            end

            collectgarbage("collect")
            _M.check_memory("> before require "..tostring(name),pad)
            local n0 =size_ceil(collectgarbage("count"))

            local ret = _M.org_require(name)

            collectgarbage("collect")
            _M.check_memory("< after  require "..tostring(name),pad)
            local n1 =size_ceil(collectgarbage("count"))

            table.remove(_M.require_queue)

            local nx =size_ceil(n1-n0)
            local msg = string.format(pad.."memory growth %.3f K @ after require %s", nx, name)
            log_mem(msg)
            log_space(pad)
            if tm == 1 then
                log_mem("")
            end
            --log_mem("-- growth "..tostring(nx).."K  after require "..tostring(name))
            _M.required_modules[name] = _M.weakref(ret)
            return ret
        else
            return ref()
            --return _M.required_modules[name]
        end
    else
        error("footprint_tracker.org_require is missing")
    end
end

local function fpt_init_core(space_name)
    if not _M.initialized then
        _M.initialized = true

        _M.org_require = _G.require        
        assert(_M.org_require ~= nil)

        log_mem("")
        log_mem("fpt_init_core called: ".. tostring(space_name))

        _M.check_memory("after init LVM",nil)

        _G.require = _M.hijack_require  --luacheck: ignore
        log_mem("require is hijacked for "..tostring(space_name))
    end
end

local function fpt_end_core(space_name)
    if not _M.initialized then
        log_mem("fpt_end_core called: ".. tostring(space_name))

        assert(_M.org_require ~= nil)
        _G.require = _M.org_require  --luacheck: ignore

        log_mem("require is restored for "..tostring(space_name))
        log_mem("")
    end
end

-- hook_start, hook_end

_M.bool_hook_started = false
function _M.hook_start(space_name)
    if not _M.bool_hook_started  then
        pcall(fpt_init_core,space_name)
    end
    _M.bool_hook_started = true
end

_M.bool_hook_ended = false
function _M.hook_end(space_name)
    if not _M.bool_hook_ended then
        pcall(fpt_end_core,space_name)
    end
end

-------------------
-- To check footprint - how to hook
--
-- --at the begining of load module
-- footprint_tracker = require('tools.footprint')
-- footprint_tracker.hook_start(space_name)
-- ...
-- ..
-- ..
-- ..
-- footprint_tracker.hook_end(space_name)
-- --before the end of the module

return _M
