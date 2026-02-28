----------------------------------------------------------------
-- CR BOOTSTRAP (Modern RP version)
----------------------------------------------------------------

local REQUIRED_SYSTEMS = {
    "core",
    "mysql",
    "models"
}

local systemStates = {}
local canConnect = false
local shuttingDown = false

----------------------------------------------------------------
-- Initialization
----------------------------------------------------------------

for _, name in ipairs(REQUIRED_SYSTEMS) do
    systemStates[name] = false
end

local function allSystemsReady()
    for _, ready in pairs(systemStates) do
        if not ready then
            return false
        end
    end
    return true
end

local function getProgress()
    local total = #REQUIRED_SYSTEMS
    local loaded = 0
    
    for _, ready in pairs(systemStates) do
        if ready then
            loaded = loaded + 1
        end
    end
    
    return loaded, total
end

----------------------------------------------------------------
-- System Ready Event
----------------------------------------------------------------

addEvent("cr:onSystemReady", true)
addEventHandler("cr:onSystemReady", root, function(systemName)
    
    if systemStates[systemName] ~= nil then
        systemStates[systemName] = true
        
        local loaded, total = getProgress()
        outputDebugString("[BOOTSTRAP] System ready: " .. systemName .. 
            " (" .. loaded .. "/" .. total .. ")", 3)
        
        if allSystemsReady() then
            canConnect = true
            outputDebugString("[BOOTSTRAP] All systems ready. Server unlocked.", 2)
        end
    end
end)

----------------------------------------------------------------
-- Connect Lock
----------------------------------------------------------------

addEventHandler("onPlayerConnect", root, function(playerName)
    
    if shuttingDown then
        cancelEvent(true, "CountrySide\nA szerver leállítás alatt van.")
        return
    end
    
    if not canConnect then
        local loaded, total = getProgress()
        cancelEvent(true, "CountrySide\nA szerver betöltés alatt van (" 
            .. loaded .. " / " .. total .. ")")
    end
end)

----------------------------------------------------------------
-- Graceful Shutdown
----------------------------------------------------------------

local function shutdownServer(admin)
    
    if shuttingDown then return end
    
    shuttingDown = true
    canConnect = false
    
    outputDebugString("[BOOTSTRAP] Server shutdown initiated.", 1)
    
    local players = getElementsByType("player")
    
    for _, player in ipairs(players) do
        kickPlayer(player, admin or "System", "A szerver leállítás alatt van!")
    end
    
    setTimer(function()
        outputDebugString("[BOOTSTRAP] Server shutting down.", 1)
        shutdown("A szerver sikeresen leállítva.")
    end, 3000, 1)
end

addCommandHandler("stopserver", function(player)
    
    if not player then
        shutdownServer("Console")
        return
    end
    
    if exports.cr_permission and exports.cr_permission:hasPermission(player, "stopserver") then
        shutdownServer(getPlayerName(player))
    end
end)