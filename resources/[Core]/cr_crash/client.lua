addEventHandler("onClientVehicleCollision", root,
    function(element)
        if element == localPlayer then
        else
            if not getPedOccupiedVehicle(localPlayer) then
            else
                local x,y,z = getElementPosition(localPlayer)
                createExplosion ( x, y, z-10, 4 ,false,-1.0,false )
                if not getElementData(localPlayer, "szivdobogas") or not getElementData(localPlayer, "toreshang") then
                    local szivdobogas = playSound("sounds/heartbeat.mp3")
                    setSoundVolume(szivdobogas, 0.5)
                    local toreshang = playSound("sounds/crash.mp3")
                    setSoundVolume(toreshang, 0.5)
                    setElementData(localPlayer, "szivdobogas", true)
                    setElementData(localPlayer, "toreshang", true)
                    setTimer(
                        function()
                            setElementData(localPlayer, "szivdobogas", false)
                            setElementData(localPlayer, "toreshang", false)
                        end, 5000, 1
                    )
                elseif getElementData(localPlayer, "szivdobogas") or getElementData(localPlayer, "toreshang") then
                end
            end
        end
    end
)

function isEventHandlerAdded(eventName, element, func)
    if type(eventName) == "string" and isElement(element) and type(func) == "function" then
        local handlers = getEventHandlers(eventName, element)
        if handlers then
            for _, v in ipairs(handlers) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

function hpszar()
    if getElementHealth(localPlayer) <= 40 then
        if not isEventHandlerAdded("onClientRender", root, vergeci) then
            addEventHandler("onClientRender", root, vergeci)
        end
    elseif getElementHealth(localPlayer) >= 50 then
        if isEventHandlerAdded("onClientRender", root, vergeci) then
            removeEventHandler("onClientRender", root, vergeci)
        end
    end
end
addEventHandler("onClientRender",root, hpszar)

function vergeci()
    dxDrawImage(0, 0, 1920, 1080,"sounds/blood.png", 0)
    dxDrawRectangle(0, 0, 1920, 1080, tocolor(64, 62, 63, 100))
end

addEventHandler("onClientResourceStart", root,
    function()
        local crashedkocsi = getPedOccupiedVehicle(localPlayer)
        if isElement(crashedkocsi) then
            setElementData(crashedkocsi, "carcrashed", false)
        end
        setElementData(localPlayer, "szivdobogas", false)
        setElementData(localPlayer, "toreshang", false)
    end
)

function jarmulerobbanas()
    local kocsi = getPedOccupiedVehicle(localPlayer)
    setElementHealth(kocsi, 0)
end
addEvent("jarmulerobbanas", true )
addEventHandler("jarmulerobbanas", localPlayer, jarmulerobbanas)

--
--
function jarmukerek1()
    local kocsi = getPedOccupiedVehicle(localPlayer)
    setVehicleWheelStates (kocsi, 1, -1, -1, -1)
end
addEvent("jarmukerek1", true )
addEventHandler("jarmukerek1", localPlayer, jarmukerek1)

--
--
function jarmukerek2()
    local kocsi = getPedOccupiedVehicle(localPlayer)
    setVehicleWheelStates (kocsi, -1, 1, -1, -1)
end
addEvent("jarmukerek2", true )
addEventHandler("jarmukerek2", localPlayer, jarmukerek2)

--
--
function jarmukerek3()
    local kocsi = getPedOccupiedVehicle(localPlayer)
    setVehicleWheelStates (kocsi, -1, -1, 1, -1)
end
addEvent("jarmukerek3", true )
addEventHandler("jarmukerek3", localPlayer, jarmukerek3)

--
--
function jarmukerek4()
    local kocsi = getPedOccupiedVehicle(localPlayer)
    setVehicleWheelStates (kocsi, -1, -1, -1, 1)
end
addEvent("jarmukerek4", true )
addEventHandler("jarmukerek4", localPlayer, jarmukerek4)

