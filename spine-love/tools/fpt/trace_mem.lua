local _M = {}

function _M.trace_mem(trace_mark, log_on)
    local n_high = collectgarbage("count")
    n_high = math.ceil(n_high*1000)/1000

    collectgarbage("collect")

    local n_low = collectgarbage("count")
    n_low = math.ceil(n_low*1000)/1000

    local lmsg = "H/L "..tostring(n_high).."K / "..tostring(n_low).."K"
    if trace_mark ~= nil then
        lmsg = lmsg.." @"..tostring(trace_mark)
    end

    if log_on then
        local log_file = require("logging.log_file")
        local lpath = log_file.get_log_pathname("footprint_mem")
        log_file.log_to_file_with_ts(lpath, lmsg)
    end

    return lmsg
end

return _M