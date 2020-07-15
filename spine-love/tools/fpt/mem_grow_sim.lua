--------------------
--  mem_grow_sim -- utils for growing memeory manually
local _M = {}

_M.data_holder = {}


local function log_mem(msg)
    local log_file = require("logging.log_file")
    local lpath = log_file.get_log_pathname("footprint_mem")
    log_file.log_to_file_with_ts(lpath, msg)
end

local function add_data_chunk_by_1k(i) --luacheck: ignore
    for loop = 1, 40 do
        table.insert(_M.data_holder,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"..tostring(100+loop))
    end
end

local function add_data_chunk_by_10K(i) --luacheck: ignore
    for loop = 1, 400 do
        table.insert(_M.data_holder,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"..tostring(100+loop))
    end
end

function _M.reset()
    _M.data_holder = {}
    collectgarbage("collect")
end

function _M.grow_fpt_by_1k(max_loop)
    log_mem("grow_fpt_by_1k started...")
    for i = 1, max_loop do
        add_data_chunk_by_1k(i)
        if i%10 == 0 then
            _M.check_memory("grow_fpt_by_1k: "..tostring(i),nil)
        end
    end
    log_mem("grow_fpt_by_1k ended")
end

function _M.grow_fpt_by_10k(max_loop)
    log_mem("grow_fpt_by_10k started...")
    for i = 1, max_loop do
        add_data_chunk_by_10K(i)
        if i%10 == 0 then
            _M.check_memory("grow_fpt_by_10k: "..tostring(i),nil)
        end
    end
    log_mem("grow_fpt_by_10k ended")
end

return _M
