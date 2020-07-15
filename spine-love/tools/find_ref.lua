local _M = {}
_M.stacks = {}
_M.table_visited = {}
_M.find_at = {}

function _M._get_table_name()
    local table_name = "_G"
    for i = 2, #_M.stacks do 
        table_name = table_name.."."..tostring(_M.stacks[i])
    end
    return table_name
end


function _M._search_ref(tbl_obj, obj)
    for key, val in pairs(tbl_obj) do
        if not (tbl_obj == _G and key == "ref_find") then
            if val == obj then
                local loc = _M._get_table_name().."."..key
                table.insert(_M.find_at, loc) 
                print("### Found at loc "..loc.." "..tostring(#_M.find_at))
            elseif type(val) == "table" then
                if not _M.table_visited[val] then
                    if #_M.stacks <= 8 then
                        table.insert(_M.stacks, key)
                        print("  search in table: ".._M._get_table_name())
                        _M._search_ref(val, obj)
                        _M.table_visited[val] = true
                        table.remove(_M.stacks, #_M.stacks)
                    end
                end
            end
        end
    end
end

function _M.find_ref()
    if _G.ref_find == nil then
        print("Please specify ref at _G.ref_find")
        return nil
    end

    _G.package.loaded.package = nil
    for i = 1 , #_M.stacks do
        _M.stacks[i] = nil
    end
    table.insert(_M.stacks, "_G")
    for key, _ in pairs(_M.table_visited) do 
        _M.table_visited[key] = nil
    end
    for j = 1, #_M.find_at do 
        _M.find_at[j] = nil
    end
    _M.table_visited[_G] = true

    _M._search_ref(_G, _G.ref_find)
    return _M.find_at
end

return _M