-- provide two type of profiler
-- line based:  profiler_line
-- func based:  profuler_func


local function profiler_get_ticks()
    if _G.sys and _G.sys.get_time_us then return _G.sys.get_time_us() / 100 end
    if _G.os.clock then return _G.os.clock()*1000000 end
    if _G.os.time then return tonumber(_G.os.time()) end
    if _G.os.ticks then return tonumber(_G.os.ticks()) end
    error('no function to support ticks')
end

local profiler_line = {}
    profiler_line.__index = profiler_line

    function profiler_line.new()
        local self = setmetatable({},profiler_line)

        self.counts = { }
        self.last_line = nil
        self.last_time = profiler_get_ticks()
        self.started = nil
        self.ended = nil

        return self
    end

    function profiler_line.activate(self)
        local function hook_counter_line(hk_name,line_no) --luacheck:ignore
            --hk_name = 'line'
            --params = 'no of the line'

            local fun_name = "unknown"
            local fun_what = "unknown"
            local fun_namewhat = "unknown"
            local func = "unknown" --luacheck:ignore
            local fun_short_src = "unknown"
            local fun_tbl = debug.getinfo(2,'nfS')
            if fun_tbl ~= nil then
                if fun_name ~= nil then
                    fun_name =  fun_tbl.name
                end
                if fun_tbl.what ~= nil then
                    fun_what = fun_tbl.what
                end
                if fun_tbl.name ~= nil then
                    fun_namewhat = fun_tbl.namewhat
                end
                if fun_tbl.func ~= nil then
                    func = fun_tbl.func
                end
                if fun_tbl.short_src ~= nil then
                    fun_short_src = fun_tbl.short_src
                end
            end

            --skip count lines used by profiler
            if fun_name == 'profiler_get_ticks' then
                return
            end
            if fun_name == "activate" and fun_namewhat == "method" then
                return
            end
            if fun_name == "deactivate" and fun_namewhat == "method" then
                return
            end
            if fun_name == 'ticks' and fun_namewhat == "field" then
                return
            end
            if fun_name == "cmd_capture_single_line" then
                return
            end

            -- all right, let's count
            local line_name = tostring(fun_name)..":"..tostring(line_no) .." @"..tostring(fun_what).."/"..tostring(fun_namewhat) .. " in "..tostring(fun_short_src) --luacheck:ignore

            local line = self.counts[line_name]
            if line == nil then
                self.counts[line_name] = { count = 0, time = 0}
                line = self.counts[line_name]
            end

            line.count  =  line.count + 1

            if self.last_line then
                local delta = profiler_get_ticks() - self.last_time
                if delta > 0 then
                    line.time = line.time + delta
                    self.last_time = profiler_get_ticks()
                end
            end

            self.last_line = line_no
        end

        self.started = profiler_get_ticks()
        debug.sethook(hook_counter_line,"l")
    end


    function profiler_line.deactivate(self)
        self.ended = profiler_get_ticks()
        debug.sethook(nil,"l")
    end

    function profiler_line.get_result(self)
        local sorted_line_names = {}
        for k,_ in pairs(self.counts) do
            table.insert(sorted_line_names,k)
        end
        table.sort(sorted_line_names)

        self.sorted_line_names = sorted_line_names
        return self.counts, self.sorted_line_names
    end

    function profiler_line.print_result(self)
        --print(self)
        --print(sorted)

        print(" count ", " ticks(s) ", "    line:func@what           ")
        print("-------", "----------","---------------------------- ")

        local line_counts, sorted_line_names = profiler_line.get_result(self)
        for _,k in ipairs(sorted_line_names) do
            local count = line_counts[k].count
            local time = math.ceil(line_counts[k].time)
            print(count,time,k)
        end
        if self.started ~= nil and self.ended ~= nil then
            print(self.ended - self.started, 'ticks in total')
        end
    end

    function profiler_line.save_result(self, fh)
        --print(self)
        --print(sorted)

        fh:write(" count ", " ticks(s) ", "    line:func@what           \n")
        fh:write("-------", "----------","---------------------------- \n")

        local line_counts, sorted_line_names = profiler_line.get_result(self)
        for _,k in ipairs(sorted_line_names) do
            local count = line_counts[k].count
            local time = math.ceil(line_counts[k].time)
            fh:write(count, "\t", time,"\t", k, "\n")
        end
        if self.started ~= nil and self.ended ~= nil then
            fh:write(self.ended - self.started, "\t", 'ticks in total', "\n")
        end
    end


local profiler_func = {}
    profiler_func.__index = profiler_func

    function profiler_func.new()
        local self = setmetatable({},profiler_func)

        self.counts = { }
        self.last_line = nil
        self.last_time = profiler_func.get_ticks()
        self.started = nil
        self.ended = nil

        return self
    end

    function profiler_func.activate(self) --luacheck:ignore
        error("not implemented")
    end

    function profiler_func.deactivate(self) --luacheck:ignore
        error("not implemented")
    end

    function profiler_func.get_result(self) --luacheck:ignore
        error("not implemented")
    end

    function profiler_func.print_result(self) --luacheck:ignore
        error("not implemented")
    end

local _M = {}
    function _M.new_line_profiler()
        return profiler_line.new()
    end

    function _M.new_func_profiler()
        return profiler_func.new()
    end

    function _M.get_ticks()
        return profiler_get_ticks()
    end

_G.has_line_hooked = true

return _M
