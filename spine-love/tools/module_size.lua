local _M = {}
_M.stacks = {}
_M.table_visited = {}

function _M.ensure_get_size()
    if _G.debug.getsize then
        return
    end
    pcall(require, "getsize")
end

function _M._get_table_name()
    local table_name = "_G"
    for i = 2, #_M.stacks do 
        table_name = table_name.."."..tostring(_M.stacks[i])
    end
    return table_name
end


function _M._sum_table(tbl_obj)
    local size = 0
    for key, val in pairs(tbl_obj) do
        if type(val) == "table" then
            if not _M.table_visited[val] then
                if #_M.stacks <= 8 then
                    table.insert(_M.stacks, key)
                    size = size + _M._sum_table(val)
                    _M.table_visited[val] = true
                    table.remove(_M.stacks, #_M.stacks)
                end
            end
        else
            size = size + _G.debug.getsize(val)
        end
    end
    return size
end

function _M.module_size()
    if _G.ref_find == nil then
        print("Please specify ref at _G.ref_find")
        return nil
    end

    _M.ensure_get_size()
    _G.package.loaded.package = nil
    for i = 1 , #_M.stacks do
        _M.stacks[i] = nil
    end
    table.insert(_M.stacks, "_G")
    for key, _ in pairs(_M.table_visited) do 
        _M.table_visited[key] = nil
    end
    _M.table_visited[_G] = true
    _M.table_visited[_G.ref_find] = true

    if type(_G.ref_find) == "table" then
        return _M._sum_table(_G.ref_find)
    end
    return _G.debug.getsize(_G.ref_find)
end

function _M.all_module_size( )
    local all_by_name = {}
    local all_by_size = {}
    local total = 0
    for key, mod in pairs(_G.package.loaded) do
        _G.ref_find = mod
        local name = key
        local nlen = string.len(name)
        for _ = nlen, 48 do 
            name = name .. " "
        end
        local size = _M.module_size()
        --print(name, size)
        all_by_name[name] = size
        all_by_size[size] = key
        total = total + size
    end
    table.sort(all_by_name)
    print(require("tools.inspect").inspect(all_by_name))
    table.sort(all_by_size)
    print(require("tools.inspect").inspect(all_by_size))
    print("total_size ", total)
end


return _M