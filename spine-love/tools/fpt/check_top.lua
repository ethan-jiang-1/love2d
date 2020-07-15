local _M = {}

-----------------------
--- environ_top - utils for checking env


_M.bool_env_session_started = false
local function fpt_check_env_core(trace_mark)
    local environ_top = require("tools.fpt.environ_top")
    local log_file = require("logging.log_file")
    local msg_env = environ_top.get_runtime_env(_G, "_G", true)
    local msg_top = environ_top.get_runtime_env_top()

    local log_filename = log_file.get_log_pathname("footprint_env")
    local file_data = io.open(log_filename, 'a+')
    if file_data ~= nil then
        if not _M.bool_env_session_started then
            file_data:write("\n\n##Footprint new session\n\n")
            _M.bool_env_session_started = true
        end

        if trace_mark ~= nil then
            file_data:write("\n\n>>Lua Runtime environment(All) @ ".. tostring(trace_mark).."\n")
            file_data:write("------------------------\n")
        end
        file_data:write("----All Symbols:\n")
        file_data:write(msg_env)
        file_data:write("----Top Symbols:\n")
        file_data:write(msg_top)
        if trace_mark ~= nil then
            file_data:write("------------------------\n")
            file_data:write("\n\n<<Lua Runtime environment(All) @ ".. tostring(trace_mark).."\n")
        end
        file_data:close()
    end
end

_M.bool_top_session_started = false
local function fpt_check_top_core(trace_mark)
    local environ_top = require("tools.fpt.environ_top")
    local log_file = require("logging.log_file")
    local msg_top = environ_top.get_runtime_env_top()

    local log_filename = log_file.get_log_pathname("footprint_top")
    local file_data = io.open(log_filename, 'a+')
    if file_data ~= nil then
        if not _M.bool_top_session_started then
            file_data:write("\n\n##Footprint new session\n\n")
            _M.bool_top_session_started = true
        end

        if trace_mark ~= nil then
            file_data:write("\n\n>>Lua Runtime environment(Top) @ ".. tostring(trace_mark).."\n")
            file_data:write("------------------------\n")
        end
        file_data:write("----Top Symbols:\n")
        file_data:write(msg_top)
        if trace_mark ~= nil then
            file_data:write("------------------------\n")
            file_data:write("\n\n<<Lua Runtime environment(Top) @ ".. tostring(trace_mark).."\n")
        end
        file_data:close()
    end
end



function _M.check_env(trace_mark)
    pcall(fpt_check_env_core,trace_mark)
end

function _M.check_top(trace_mark)
    pcall(fpt_check_top_core,trace_mark)
end

return _M