addEventHandler("onResourceStart", resourceRoot, function()

    aclReload()

    setMapName(Core.Config.name)
    setGameType("RP " .. Core.Config.version)
    setRuleValue("modversion", Core.Config.version)

    Core.State.serverReady = true

    local loadTime = getTickCount() - Core.State.startTick
    Core.Debug("Core initialized in " .. loadTime .. " ms")

    triggerEvent("cr:onCoreReady", root)
end)

function Core.getPlayers()
    return getElementsByType("player")
end

function Core.getPlayerCount()
    return #getElementsByType("player")
end