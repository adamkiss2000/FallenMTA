function formatRPName(name)
    if not name then return nil end

    name = string.lower(name)

    if select(2, name:gsub("_", "")) ~= 1 then
        return nil
    end

    local first, last = name:match("^(%a+)_+(%a+)$")
    if not first or not last then
        return nil
    end

    if #first < 3 or #last < 3 then
        return nil
    end

    if not first:match("^[a-z]+$") then return nil end
    if not last:match("^[a-z]+$") then return nil end

    first = first:sub(1,1):upper() .. first:sub(2)
    last  = last:sub(1,1):upper() .. last:sub(2)

    return first .. "_" .. last
end
