Player.State = {}

function Player.isLoggedIn(player)
    return Player.State[player] == true
end

function Player.setLoggedIn(player, state)
    if not isElement(player) then return false end

    if state then
        Player.State[player] = true
        setElementData(player, "player:loggedIn", true)
    else
        Player.State[player] = nil
        setElementData(player, "player:loggedIn", false)
    end

    return true
end