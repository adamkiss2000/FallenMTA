Core = Core or {}
Core.Utils = {}

function Core.Utils.tableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function Core.Utils.isValidElement(e)
    return e and isElement(e)
end