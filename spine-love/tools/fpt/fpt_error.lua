local _M = {}

function _M.log_error_core(err)
    local log_file = require("logging.log_file")
    local log_name = "footprint_err"

    local log_line = " Exception: "..tostring(err)
    log_file.log_to_file_with_ts(log_name, log_line)

    log_line = " StackTrace: ".. tostring(_M.get_traceback(""))
    log_file.log_to_file_with_ts(log_name, log_line)
end

function _M.get_traceback(trace_msg)
    local level = 2 -- not include this function in stack
    local ret = " stack_traceback: "..tostring(trace_msg).."\n"
    while true do
        --get stack info
        local info = debug.getinfo(level, "Sln")
        if not info then break end
        if info.what == "C" then
            ret = ret .."\t"..tostring(level-1) .. "\tC function\n"
        else
            ret = ret .."\t"..tostring(level-1)..string.format("\t[%s]:%d in function \'%s\'\n", info.short_src, info.currentline, info.name or "") --luacheck: ignore
        end
        level = level + 1
    end
    return ret
end

function _M.log_error(err)
    pcall(_M.log_error_core, err)
end


return _M