local _M = {}

--local log_file = require("logging.log_file")

local function size_ceil(n)
    return  math.ceil(n*1000)/1000
end

---------
--- footprint_tracker.check functions
--   check_memory
--   check_module

function _M.log_mem(msg)
    print(msg)
    --local lpath = log_file.get_log_pathname("footprint_mem")
    --log_file.log_to_file_with_ts(lpath, msg)
end

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

function _M.check_memory(trace_mark, pad)
    pcall(fpt_check_memory_core,trace_mark,pad)
end

local function fpt_check_module_core(trace_mark)
    local msg  = "Module loaded @ "..tostring(trace_mark).. ":"
    _M.log_mem(msg)
    msg = "{"
    for k, _ in pairs(package.loaded) do
        if string.len(msg) == 1 then
            msg = msg .. '\"'..tostring(k)..'\"'
        else
            msg = msg .. ', \"'..tostring(k)..'\"'
        end
    end
    msg = msg .."}"
    _M.log_mem(msg)
end

function _M.check_module(trace_mark)
    pcall(fpt_check_module_core,trace_mark)
end

-------------------
-- _M.check_module(check_name)
-- _M.check_memory(check_name)

-----------------
return _M
