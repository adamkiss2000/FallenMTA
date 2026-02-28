MySQL.Queue = {}

local function processQueue()
    if not MySQL.isConnected() then return end

    for i = #MySQL.Queue, 1, -1 do
        local job = MySQL.Queue[i]
        table.remove(MySQL.Queue, i)
        job()
    end
end

function MySQL.exec(query, ...)
    if not MySQL.isConnected() then
        table.insert(MySQL.Queue, function()
            MySQL.exec(query, ...)
        end)
        return false
    end

    local startTick = getTickCount()
    local result = dbExec(MySQL.Connection, query, ...)
    local duration = getTickCount() - startTick

    if MySQL.Config.debug then
        outputDebugString("[MySQL][EXEC] " .. query)
    end

    if duration > MySQL.Config.slowQueryThreshold then
        outputDebugString("[MySQL][SLOW QUERY] " .. duration .. " ms → " .. query, 2)
    end

    return result
end

function MySQL.query(query, callback, ...)
    if not MySQL.isConnected() then
        table.insert(MySQL.Queue, function()
            MySQL.query(query, callback, ...)
        end)
        return false
    end

    local startTick = getTickCount()

    dbQuery(function(qh)
        local result = dbPoll(qh, 0)
        local duration = getTickCount() - startTick

        if MySQL.Config.debug then
            outputDebugString("[MySQL][QUERY] " .. query)
        end

        if duration > MySQL.Config.slowQueryThreshold then
            outputDebugString("[MySQL][SLOW QUERY] " .. duration .. " ms → " .. query, 2)
        end

        if callback then
            callback(result)
        end
    end, MySQL.Connection, query, ...)

    return true
end