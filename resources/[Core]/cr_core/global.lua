-- Server basic data
serverData = {
    name = "FallenMTA",
    version = "1.0",
    color = {255, 140, 0}
}

function getServerData()
    return serverData
end

function getServerColor()
    return unpack(serverData.color)
end

function getVersion()
    return serverData.version
end

function getServerSyntax()
    local r,g,b = getServerColor()
    return "#"..string.format("%02X%02X%02X", r,g,b)..serverData.name.." #FFFFFF» "
end


-- ======================
-- Utility Functions
-- ======================

function math.round(num)
    return math.floor(num + 0.5)
end

function split(str, sep)
    local result = {}
    for part in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(result, part)
    end
    return result
end

function formatTimeStamp()
    local time = getRealTime()
    return string.format("%02d:%02d:%02d",
        time.hour,
        time.minute,
        time.second
    )
end


-- ======================
-- Player Finder
-- ======================

function findPlayer(sourcePlayer, target)
    if not target then return false end

    -- ID alapú keresés
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "playerID") == tonumber(target) then
            return player
        end
    end

    -- név alapú keresés
    target = string.lower(target)
    for _, player in ipairs(getElementsByType("player")) do
        if string.find(string.lower(getPlayerName(player)), target, 1, true) then
            return player
        end
    end

    return false
end