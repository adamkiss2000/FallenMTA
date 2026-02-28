local maxPing = 300
mT=setTimer(
    function() 
        if getPlayerPing(getLocalPlayer()) >= maxPing then 
            triggerServerEvent("ping.onBigPing",getLocalPlayer(),getPlayerPing(getLocalPlayer()))
        end
    end,
5000,0)

addEvent("ping.killPing",true)
addEventHandler("ping.killPing",getRootElement(),function() killTimer(mT) end)
