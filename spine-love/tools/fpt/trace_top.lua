local _M = {}

_M.bool_trace_top_first_round = true
function _M.trace_top(trace_mark, log_on)
    local environ_top = require("tools.fpt.environ_top")
    local top_changed = environ_top.get_top_changes()

    local lmsg = ""
    if not _M.bool_trace_top_first_round then
        for k,v in pairs(top_changed) do
            lmsg = lmsg.."  "..tostring(k).." : "..tostring(v).."\n"
        end
        if string.len(lmsg) ~= 0 then
            lmsg = "Top changed @"..tostring(trace_mark)..":\n"..lmsg
        end
    else
        lmsg = "Top change trace marked @"..tostring(trace_mark)
    end
    if log_on then
        local log_file = require("logging.log_file")
        local lpath = log_file.get_log_pathname("footprint_top")
        log_file.log_to_file_with_ts(lpath, lmsg)
    end

    _M.bool_trace_top_first_round = false
    return lmsg
end


return _M