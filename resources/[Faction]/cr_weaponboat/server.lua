local cache = {
    ["ship"] = {},
    ["crates"] = {},
}

factionIds = {
    6,
    7,
    9,
    10,
    11,
    12,
    13,
    14,
}

local shipDestroyTimer = false
local shipCheckTimer = false

function createShip()
    cache["ship"][1] = Object(shipObjectId, shipStartPoint, 0, 0, objectRotation)

    local interiorPoint = Vector3(shipStartPoint.x - 14.7188, shipStartPoint.y + 1.05, 7.125)
    cache["ship"][2] = Object(shipInteriorObjectId, interiorPoint, 0, 0, objectRotation)

    local framePoint = Vector3(shipStartPoint.x + 0.250, shipStartPoint.y + 1.4, shipStartPoint.z - 1.14844)
    cache["ship"][3] = Object(shipFrameObjectId, framePoint, 0, 0, objectRotation)

    local stairsFramePoint = Vector3(shipStartPoint.x - 44.3906, shipStartPoint.y - 0.7656, shipStartPoint.z - 0.75781)
    cache["ship"][4] = Object(shipStairsFrameObjectId, stairsFramePoint, 0, 0, objectRotation)

    local boxesPoint = Vector3(shipStartPoint.x + 0.9, shipStartPoint.y + 1.495, shipStartPoint.z + 1)
    cache["ship"][5] = Object(shipBoxesObjectId, boxesPoint, 0, 0, objectRotation)

    local shipRotationPoint = Vector3(0, 0, 0)
    cache["ship"][1]:move(moveTime, shipEndPoint, shipRotationPoint, "InOutQuad")

    local interiorPoint = Vector3(shipEndPoint.x - 14.7188, shipEndPoint.y + 1.05, 7.125)
    cache["ship"][2]:move(moveTime, interiorPoint, shipRotationPoint, "InOutQuad")

    local framePoint = Vector3(shipEndPoint.x + 0.250, shipEndPoint.y + 1.4, shipEndPoint.z - 1.14844)
    cache["ship"][3]:move(moveTime, framePoint, shipRotationPoint, "InOutQuad")

    local stairsFramePoint = Vector3(shipEndPoint.x - 44.3906, shipEndPoint.y - 0.7656, shipEndPoint.z - 0.75781)
    cache["ship"][4]:move(moveTime, stairsFramePoint, shipRotationPoint, "InOutQuad")

    local boxesPoint = Vector3(shipEndPoint.x + 0.9, shipEndPoint.y + 1.495, shipEndPoint.z + 1)
    cache["ship"][5]:move(moveTime, boxesPoint, shipRotationPoint, "InOutQuad")

    local codePoint = Vector3(shipStartPoint.x-47.2, shipStartPoint.y + 0.35, 12)
    cache["ship"][6] = Object(2886, codePoint,0,0,270)

    local codePoint = Vector3(shipEndPoint.x-47.2, shipEndPoint.y + 0.35, 12)
    cache["ship"][6]:move(moveTime, codePoint, shipRotationPoint, "InOutQuad")

    cache["ship"][6]:setData("hackPanel", true)
    cache["ship"][6]:setData("isHacked", false)
    cache["ship"][6]:setData("badHacked", false)

    local gatePoint = Vector3(shipStartPoint.x-47.1, shipStartPoint.y-1.2, 11.8)
    cache["ship"][7] = Object(3109, gatePoint)

    local gatePoint = Vector3(shipEndPoint.x-47.1, shipEndPoint.y-1.2, 11.8)
    cache["ship"][7]:move(moveTime, gatePoint, shipRotationPoint, "InOutQuad")

    setTimer(
        function()
            local randomPlayer = getRandomPlayer()

            if randomPlayer then 
                local players = getElementsByType("player")

                triggerClientEvent(players, "playShipHornSound", randomPlayer)
                initMarker()
            end

            createCrates()
            notifyFactions("arrival")
        end, moveTime, 1
    )
end
addCommandHandler("createship", createShip)

function destroyShip()
    for i = 1, 7 do 
        local v = cache["ship"][i]

        if v then 
            v:destroy()
        end
    end

    cache["ship"] = {}
    collectgarbage("collect")
end

function createCrates()
    for i = 1, #crates do 
        local v = crates[i]

        if v then 
            local x, y, z, rx, ry, rz = unpack(v)

            local obj = Object(ammoBoxObjectId, x, y, z, rx, ry, rz)

            obj:setData("weaponcrate >> id", i)
            obj:setData("isInteractable", true)

            cache["crates"][i] = obj
        end
    end
end

function destroyCrates()
    for i = 1, #cache["crates"] do 
        local v = cache["crates"][i]

        if v then 
            if isElement(v) then 
                v:destroy()
            end
        end
    end

    collectgarbage("collect")
end

function notifyFactions(state)
    local syntax = exports["cr_core"]:getServerSyntax("Weaponship", "red")
    local yellowHex = exports["cr_core"]:getServerColor("yellow", true)
    local serverHex = exports["cr_core"]:getServerColor("blue", true)

    if state == "arrival" then
        for k, v in pairs(factionIds) do  
            exports["cr_dashboard"]:sendMessageToFaction(k, syntax.."A fegyverhajó megérkezett a "..yellowHex.."Nyugati kikötőbe"..white.." és "..serverHex..shipStayTime..white.." percig fog ott maradni.")
        end
        if isTimer(shipDestroyTimer) then 
            killTimer(shipDestroyTimer)

            shipDestroyTimer = nil
        end

        shipDestroyTimer = setTimer(
            function()
                destroyCrates()
                destroyShip()

                shipDestroyTimer = nil
            end, 60000 * shipStayTime, 1
        )

        if isTimer(shipCheckTimer) then 
            killTimer(shipCheckTimer)

            shipCheckTimer = nil
        end

        shipCheckTimer = setTimer(
            function()
                local remaining, executesRemaining, timeInterval = shipDestroyTimer:getDetails()
                local minutesLeft = math.ceil((remaining / 1000) / 60)

                if minutesLeft <= 5 then 
                    local randomPlayer = getRandomPlayer()

                    if randomPlayer then 
                        local players = getElementsByType("player")

                        triggerClientEvent(players, "playShipHornSound", randomPlayer)
                        
                        notifyFactions("getaway")
                    end

                    if isTimer(shipCheckTimer) then 
                        killTimer(shipCheckTimer)
                        
                        shipCheckTimer = nil
                    end
                end
            end, 1000, 0
        )
    elseif state == "getaway" then 
        for k, v in pairs(factionIds) do  
            exports["cr_dashboard"]:sendMessageToFaction(k, syntax.."A fegyverhajó megérkezett a "..yellowHex.."Nyugati kikötőbe"..white.." és "..serverHex..shipStayTime..white.." percig fog ott maradni.")
        end
    end
end

addEvent("weaponship.pickupCrate", true)
addEventHandler("weaponship.pickupCrate", root,
    function(thePlayer, element)
        if client and client == thePlayer and element and isElement(element) then 
            local id = element:getData("weaponcrate >> id")

            if id and id > 0 then 
                if cache["crates"][id] then 
                    cache["crates"][id] = nil
                end
                
                setElementData(element, "isInteractable", false)
                attachCrateToPlayer(thePlayer, element)

                collectgarbage("collect")
            end
        end
    end
)

function attachCrateToPlayer(thePlayer,element)
    if isElement(thePlayer) then 
        local obj = element
        thePlayer:setData("weaponcrate >> inHand", obj)

        exports["cr_bone_attach"]:attachElementToBone(obj, thePlayer, 12, 0.25, 0.05, 0.15, -90, 0, -20)
        thePlayer:setAnimation("carry", "crry_prtial", 1, true, false, true, true)

        triggerLatentClientEvent(thePlayer, "carryRestriction", 50000, false, thePlayer, false)
    end
end

function detachCrateFromPlayer(thePlayer, drop)
    if thePlayer then
        if drop then 
            local obj = thePlayer:getData("weaponcrate >> inHand")
            local id = getElementData(obj, "weaponcrate >> id")
	        if isElement(obj) and id then
                local fx, fy, fz, rot = getPositionInfrontOfElement(thePlayer, 1)
                exports["cr_bone_attach"]:detachElementFromBone(obj)
                obj:destroy()
                local obj = Object(ammoBoxObjectId,fx, fy, fz-0.92)
                setElementRotation(obj, 0, 0, rot)
                setElementData(obj, "weaponcrate >> id", id)
                setElementData(obj, "isInteractable", true)
                thePlayer:setData("weaponcrate >> inHand", nil)
                thePlayer:setAnimation(nil, nil)
                triggerLatentClientEvent(thePlayer, "carryRestriction", 50000, false, thePlayer, true)
                collectgarbage("collect")
            end
        else

            local obj = thePlayer:getData("weaponcrate >> inHand")
            if obj and isElement(obj) then 
                exports["cr_bone_attach"]:detachElementFromBone(obj)
                obj:destroy()

                thePlayer:setData("weaponcrate >> inHand", nil)
                thePlayer:setAnimation(nil, nil)

                triggerLatentClientEvent(thePlayer, "carryRestriction", 50000, false, thePlayer, true)

                collectgarbage("collect")
            end
        end
    end
end
addEvent("weaponship.detachCrateFromPlayer", true)
addEventHandler("weaponship.detachCrateFromPlayer", root, detachCrateFromPlayer)


function succesHackedServer()
	local gatePoint = Vector3(shipEndPoint.x-47.1, shipEndPoint.y-2.9, 11.8)
    cache["ship"][7]:move(10000, gatePoint, shipRotationPoint, "InOutQuad")
end
addEvent("succesHackedServer", true)
addEventHandler("succesHackedServer", root, succesHackedServer)

function dropWeaponBox(player)
    detachCrateFromPlayer(player, true)
end
addEvent("dropWeaponBoxSync", true)
addEventHandler("dropWeaponBoxSync", root, dropWeaponBox)

function getPositionInfrontOfElement(element, meters)
    if (not element or not isElement(element)) then return false end
    local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = getElementPosition(element)
    local _, _, rotation = getElementRotation(element)
    posX = posX - math.sin(math.rad(rotation)) * meters
    posY = posY + math.cos(math.rad(rotation)) * meters
    rot = rotation + math.cos(math.rad(rotation))
    return posX, posY, posZ , rot
end

function quitPlayer ()
	local obj = source:getData("weaponcrate >> inHand") or nli
	if isElement(obj) then
        local id = getElementData(obj, "weaponcrate >> id")
        exports["cr_bone_attach"]:detachElementFromBone(obj)
        obj:destroy()
        local fx, fy, fz, rot = getPositionInfrontOfElement(source, 0.5)
        local obj = createObject(2358, fx, fy, fz-0.92)
        setElementRotation(obj, 0, 0, rot)
        setElementData(obj, "isInteractable", true)
        setElementData(obj, "weaponcrate >> id", id)
        collectgarbage("collect")
    end
end
addEventHandler ( "onPlayerQuit", root, quitPlayer )

function getItem()
	local rnd = math.random(1, 100)
	local chance = #loot/(#loot+rnd) * 180
	local wItemTable = {}
	local winItem = nil
	
	for i, v in ipairs(loot) do
		if math.floor(100-chance) <= v[4] then
			table.insert(wItemTable, v)
		end
	end
	
	if #wItemTable > 0 then
		local rnd2 = math.random(1, #wItemTable)
		
		for i, v in ipairs(wItemTable) do
			if i == rnd2 then
				winItem = v
			end
		end
	else
		return 0
	end
	
	return winItem
end

function OpenBox(hitElement, create)
    local syntax = exports["cr_core"]:getServerSyntax("Weaponship", "red")
    local yellowHex = exports["cr_core"]:getServerColor("yellow", true)
    local serverHex = exports["cr_core"]:getServerColor("blue", true)
	if getElementData(hitElement, "weaponcrate >> inHand") then
		local item = getItem()

		if item ~= 0 then
			if exports['cr_inventory']:isElementHasSpace(hitElement, nil, item[1], 1, 1, 1) then
				exports['cr_inventory']:giveItem(hitElement, item[1], 1, 1, 100, 0, 0, 0)
				outputChatBox(syntax .. "A láda "..yellowHex..item[3].." db "..yellowHex..item[2].."-t rejtett.", hitElement, 255, 255, 255, true)
                detachCrateFromPlayer(hitElement)
			else
				exports['cr_infobox']:addBox(hitElement, "error", "Nincs elég hely az inventoryban!")
			end
		else
            outputChatBox(syntax .."A láda üres volt.", hitElement, 255, 255, 255, true)
            detachCrateFromPlayer(hitElement)
		end
        
	end
end


function initMarker()
    local r, g, b = exports["cr_core"]:getServerColor("lightyellow", false)
    local weaponMarker = Marker(weaponMarkerPoint, "cylinder", 2, r, g, b, 150)
    weaponMarker:setData("marker >> customMarker", true)
    weaponMarker:setData("marker >> customIconPath", ":cr_weaponboat/files/images/weapon.png")
    addEventHandler("onMarkerHit", weaponMarker,
        function(hitElement, mDim)
            if hitElement and getElementType(hitElement) == "player" then 
                if mDim then 
                    local crate = hitElement:getData("weaponcrate >> inHand")
                    if crate and isElement(crate) then 
                        OpenBox(hitElement, crate)
                    end
                end
            end
        end
    )
end