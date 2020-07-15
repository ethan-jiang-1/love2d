local _M = {}
_M.stacks = {}
_M.table_visited = {}

function _M._ensure_get_size()
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


function _M._sum_size_table(tbl_obj)
    local size = _G.debug.getsize(tbl_obj)
    for key, val in pairs(tbl_obj) do
        if not (tbl_obj == _G and key == "ref_find") then
            if type(val) == "table" then
                if not _M.table_visited[val] then
                    if #_M.stacks <= 8 then
                        table.insert(_M.stacks, key)
                        size = size + _M._sum_size_table(val)
                        _M.table_visited[val] = true
                        table.remove(_M.stacks, #_M.stacks)
                    end
                end
            else
                size = size + _G.debug.getsize(val)
            end
        end
    end
    return size
end

function _M._sum_size_obj(obj)
    if type(obj) == "table" then
        return _M._sum_size_table(obj)
    end
    return _G.debug.getsize(obj)
end

function _M.obj_size()
    if _G.ref_find == nil then
        print("Please specify ref at _G.ref_find")
        return nil
    end
    _M._ensure_get_size()    

    _G.package.loaded.package = nil
    for i = 1 , #_M.stacks do
        _M.stacks[i] = nil
    end
    table.insert(_M.stacks, "_G")
    for key, _ in pairs(_M.table_visited) do 
        _M.table_visited[key] = nil
    end
    _M.table_visited[_G] = true

    local size = _M._sum_size_obj(_G.ref_find)
    return size
end

return _M