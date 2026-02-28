addEventHandler("onPlayerJoin", root, function()
    Player.setLoggedIn(source, false)

    setElementDimension(source, Player.Config.loginDimension)
    setElementAlpha(source, 0)
    setElementFrozen(source, true)

    triggerClientEvent(source, "cr_player:showLogin", source)
end)

addEventHandler("onPlayerQuit", root, function()
    Player.State[source] = nil
end)