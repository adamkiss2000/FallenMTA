local screenX, screenY = guiGetScreenSize()
local doorSphere = createColSphere (-1087.9339599609, -297.11727905273, 11.47031211853, 1 )
local alpha = 0

local currentItem = 1
local itemToGet = false

local caseOpening = false
local openButtonHover = false

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


function hasPermission(factionId, permName)
    if factionId and permName then
        --print(exports.cr_dashboard:hasPlayerPermission(localPlayer, factionId, "weaponBoat"))
        if exports.cr_dashboard:hasPlayerPermission(localPlayer, factionId, "weaponBoat") or exports.cr_dashboard:isPlayerFactionLeader(localPlayer, factionId) then 
            return true
        end
    end

    return false
end

function hasPermissionToRob(robType)
    local robType = "weaponBoat"
    local result = false

    for i = 1, #factionIds do 
        local v = factionIds[i]

        if v then 
            if hasPermission(v, robType) then 
                result = true
                break
            end
        end
    end

    return result
end

addEvent("playShipHornSound", true)
addEventHandler("playShipHornSound", root,
    function()
        local soundElement = Sound3D("files/sounds/shiphorn.mp3", shipEndPoint)

        soundElement.interior = soundInterior
        soundElement.dimension = soundDimension
        soundElement:setMaxDistance(maxSoundDistance)
    end
)

addEventHandler("onClientClick", root,
    function(button, state, absX, absY, worldX, worldY, worldZ, clickedElement)
        if button == "left" then 
            if state == "down" then 
                if isElement(clickedElement) and clickedElement.type == "object" and getDistanceBetweenPoints3D(clickedElement.position,localPlayer.position) < 2 then 
                    print(clickedElement:getData("weaponcrate >> id"),localPlayer:getData("weaponcrate >> inHand"),clickedElement:getData("isInteractable"),hasPermissionToRob())
                    if clickedElement:getData("weaponcrate >> id") and clickedElement:getData("isInteractable") and hasPermissionToRob() then
                        if localPlayer:getData("weaponcrate >> inHand") == false or localPlayer:getData("weaponcrate >> inHand") == nil then 
                            triggerLatentServerEvent("weaponship.pickupCrate", 5000, false, localPlayer, localPlayer, clickedElement)
                        end
                    end
                end
            end
        end
    end
)


local valueTimer
function carryRestriction(value)
    if isTimer(valueTimer) then killTimer(valueTimer) end
    valueTimer = setTimer(
        function()
            toggleControl("jump", value)
            toggleControl("fire", value)
            toggleControl("action", value)
            toggleControl("crouch", value)
            toggleControl("sprint", value)
        end, 200, 1
    )
end
addEvent("carryRestriction", true)
addEventHandler("carryRestriction", root, carryRestriction)

function interctionInfo()
    if hasPermissionToRob() then 
        local font = exports["cr_fonts"]:getFont("Roboto", 10)
        if localPlayer:getData("weaponcrate >> inHand") then
            dxDrawText("A doboz lerakásához használd az e gombot.", screenX+2, screenY + 750+2, 0, 0, tocolor(0, 0, 0), 1, font, "center", "center", false, false, false, true)
            dxDrawText("A doboz lerakásához használd az #32b3efe #ffffffgombot.", screenX, screenY + 750, 0, 0, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true)
        end
        
        if isElementWithinColShape(localPlayer, doorSphere) then
            for _, v in ipairs(getElementsByType("object")) do
                if getElementData(v, "hackPanel") then
                    if not getElementData(v, "hacked") then
                        dxDrawText("A feltöréshez használd az e gombot.", screenX+2, screenY + 870+2, 0, 0, tocolor(0, 0, 0), 1, font, "center", "center", false, false, false, true)
                        dxDrawText("A feltöréshez használd az #32b3efe #ffffffgombot.", screenX, screenY + 870, 0, 0, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientRender", root, interctionInfo)

bindKey("e", "down", function(key, state)
	if isElementWithinColShape(localPlayer, doorSphere) then
		for _, v in ipairs(getElementsByType("object")) do
			if getElementData(v, "hackPanel") then
				if getElementData(v, "hacked") then return end
				if not getElementData(v, "badHacked") then
					if not getElementData(v, "isHacked") then
						setElementData(v, "isHacked", true)
						exports["cr_minigame"]:createMinigame(localPlayer, math.random(1, 3), "cr_weaponboat")
					else
						exports['cr_infobox']:addBox(localPlayer, "error", "Már hackelik az ajtót!")
					end
				else
                    exports['cr_infobox']:addBox(localPlayer, "error", "Elrontották a hackelését ezért nem nyitható ki az ajtó!")
				end
			end
		end
	end

	if localPlayer:getData("weaponcrate >> inHand") then
		triggerServerEvent("dropWeaponBoxSync", localPlayer, localPlayer)
	end
end)

addEvent("[Minigame - StopMinigame]", true)
addEventHandler("[Minigame - StopMinigame]", root,
function(thePlayer, array)
    if thePlayer == localPlayer and array[2] == "cr_weaponboat" then 
        if array[3] >= array[5] then 
            exports["cr_infobox"]:addBox("success", "Sikeresen feltörted az ajtót!")
            exports["cr_chat"]:createMessage(localPlayer, "Feltört egy ajtót.", "do")
                for _, v in ipairs(getElementsByType("object")) do
                    if getElementData(v, "hackPanel") then
                        setElementData(v, "hacked", true)
                    end
                end
                
                triggerServerEvent("succesHackedServer", localPlayer)
            else 
                exports["cr_infobox"]:addBox("error", "Elrontottad az ajtó hackelést!")
                for _, v in ipairs(getElementsByType("object")) do
                    if getElementData(v, "hackPanel") then
                        setElementData(v, "badHacked", true)
                    end
                end
            end
        end
    end
)