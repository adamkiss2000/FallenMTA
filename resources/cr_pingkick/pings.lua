local warningCount = 0
local maxPing = 300

function killMyPing (thePlayer)
    triggerClientEvent ( thePlayer, "ping.killPing", getRootElement())
    outputChatBox("[CountrySide] Túllépted a megengedett pinget!",thePlayer,0,255,0)
end


function onPingHighServer()
    local warnings = getElementData(source,"warnings")
    if not warnings then setElementData(source,"warnings",1) warnings = 1 end
    if warnings < warningCount then setElementData(source,"warnings",warnings+1)
    
    else 
    kickPlayer(source,source,"[CountrySide] Túllépted a megengedett pinget!") 
    end
end
addEvent( "ping.onBigPing", true )
addEventHandler( "ping.onBigPing", getRootElement(), onPingHighServer )
