addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[cr_player] Player system initialized.")
end)

addEvent("cr_player:spawnPlayer", true)
addEventHandler("cr_player:spawnPlayer", root, function()
    if not Player.isLoggedIn(client) then return end

    setElementDimension(client, Player.Config.spawnDimension)
    setElementAlpha(client, 255)
    setElementFrozen(client, false)

    spawnPlayer(client, 0, 0, 5)
end)