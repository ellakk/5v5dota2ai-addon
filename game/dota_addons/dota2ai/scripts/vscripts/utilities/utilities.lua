local Utilities = {}

---@param table_to_search any[] | table<any, any>
---@param value_to_find any
---@return boolean
function Utilities:Table_includes_value(table_to_search, value_to_find)
    for _index, value in ipairs(table_to_search) do
        if value == value_to_find then
            return true
        end
    end

    return false
end

---@param table_to_count any[] | table<any, any>
---@return integer
function Utilities:Get_table_length(table_to_count)
    local count = 0
    for _ in pairs(table_to_count) do
        count = count + 1
    end
    return count
end

---@param vector table
---@return table
function Utilities:Vector_to_array(vector)
    return {vector.x, vector.y, vector.z}
end

---@param original_list any[]
---@param list_to_add any[]
function Utilities:Insert_range(original_list, list_to_add)
    for _index, value in ipairs(list_to_add) do
        table.insert(original_list, value)
    end
end

--- Concat 2 one-dimensional tables.
---@param list_a any[]
---@param list_b any[]
---@return table new_list new one-dimensional table with all values from both lists.
function Utilities:Concat_lists(list_a, list_b)
    local new_list = {}
    for _index, value in ipairs(list_a) do
        table.insert(new_list, value)
    end
    for _index, value in ipairs(list_b) do
        table.insert(new_list, value)
    end
    return new_list
end

---@param any any
---@return boolean
function Utilities:To_bool(any)
    return not not any
end

---@param to_round number
---@return integer
function Utilities:Round_whole(to_round)
    return math.floor(to_round + 0.5)
end

return Utilities