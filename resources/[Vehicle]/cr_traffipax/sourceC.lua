local Traffis = {}
local colShape = {}
local colShaperadaros = {}

local trafiBlip = {}
local blipState = false

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

local traffiPos = {--X, Y, Z, Rot[1,2,3], speedLimit, colshape elheleyzekédes X, Y
	{ 1344.8094482422, 401.61636352539, 19.5546875,0, 0, 114, 50, 1363.7227783203, 416.85430908203, 19.40625, 11},--Autóker
	{1402.2739257812, 188.58648681641, 19.944133758545,0, 0, 100, 90, 1427.380859375, 187.00991821289, 21.266651153564, 10},--Montgomery autópálya felé
	{999.662109375, 402.03317260742, 20.446226119995,0, 0, 294, 90, 934.49304199219, 373.66812133789, 19.8828125, 10},--Red County erdő
	{1428.2504882812, 412.67721557617, 19.980094909668,0, 0, 233, 90, 1417.8654785156, 425.53659057617, 19.890598297119, 8},-- Autóker mögött
	{252.96734619141, -361.86260986328, 8.8481349945068,0, 0, 68, 90, 283.28829956055, -379.19735717773, 8.9242248535156, 10},--Blueberry híd
	{873.13653564453, -571.57141113281, 18.386436462402,0, 0, 134, 90, 903.89886474609, -547.32427978516, 25.476757049561, 8},--Montgomery 
	{1307.642578125, -52.503517150879, 35.543243408203,0, 0, 120, 90, 1350.7775878906, -35.449081420898, 34.62614440918, 8},--Red County erdő 2 
	{1259.5440673828, 210.04425048828, 25.6484375,0, 0, 0, 50, 1252.2838134766, 164.19975280762, 19.451219558716, 8},--Montgomery
	{2062.8784179688, 51.977077484131, 26.809852600098,0, 0, 289, 90, 2017.2045898438, 39.857009887695, 30.285774230957, 8},--Palo híd
	{2486.3625488281, 285.19253540039, 31.355972290039,0, 0, 245, 120, 2412.6938476562, 321.21786499023, 32.6640625, 15},--Palo autópálya
	{47.638771057129, -219.59739685059, 1.5779839754105,0, 0, 260, 90, -2.2891671657562, -206.42286682129, 1.5274786949158, 8},--Blueberry bányász
	{171.87268066406, 55.068855285645, 2.4022812843323,0, 0, 238, 90, 145.42572021484, 74.927505493164, 2.078125, 8},--Blueberry
	{243.15440368652, -188.77458190918, 10.096265792847,0, 0, 340, 50, 232.78807067871, -211.76737976074, 1.4290393590927, 16},--Blueberry
	{528.39538574219, 171.17562866211, 22.22464942932,0, 0, 346, 90, 523.46435546875, 120.9959564209, 23.321659088135, 8},--Blueberry
	{668.54718017578, -505.32962036133, 22.8359375,0, 0, 220, 50, 641.80303955078, -483.81500244141, 16.1875, 13},--Dillimore

}

function createTraffi ()
	for i,v in ipairs (traffiPos) do
		Traffis[i] = createObject(951, v[1],v[2],v[3]-1.04,v[4], v[5], v[6])
		engineSetModelLODDistance(951, 100)
		--colShaperadaros[i] = createColSphere(v[8],v[9],v[10]-1,v[11]+80)
		colShape[i] = createColSphere(v[8],v[9],v[10]-1,v[11])
		--setElementData(colShaperadaros[i],"traffipax.object", true)
		setElementData(colShape[i], "traffipax.object", true)
		setElementData(colShape[i], "colshape.ID", i)

		txd = engineLoadTXD("files/traffi_allo.txd") 
		col = engineLoadCOL("files/traffi_allo.col") 
		dff = engineLoadDFF("files/traffi_allo.dff", 0) 
		
		engineImportTXD(txd, 951) 
		engineReplaceCOL(col, 951) 
		engineReplaceModel(dff, 951) 
	end
 end
 addEventHandler ( "onClientResourceStart", resourceRoot, createTraffi)


local ignoreModel = {
    [596] = true,
    [598] = true,
    [597] = true,
    [575] = true,
    [416] = true,
}
 
local noBeltTicket = 150
local white = "#ffffff"
spam = -500

addEventHandler("onClientColShapeHit", root, 
    function(thePlayer, matchingDimension)
        if not isElement(source) then return end
        if thePlayer == localPlayer and getTickCount() >= spam + 10000 then
            if getElementData(source, "traffipax.object") then
                local veh = getPedOccupiedVehicle(localPlayer)
                if veh and getPedOccupiedVehicleSeat(localPlayer) == 0 then
                    local speed = math.floor(getElementSpeed(veh), 1)
					local colshapeID = getElementData(source, "colshape.ID")
                    local maxSpeed = traffiPos[colshapeID][7] or 30
                    local syntax = exports['cr_core']:getServerSyntax("Traffipax", "error")
                    local green = exports['cr_core']:getServerColor("yellow", true)
                    local model = getElementModel(veh)
                    if speed > maxSpeed and math.abs(speed - maxSpeed) > 5 then
                        local ticket = math.floor((speed - maxSpeed) * 10)
                        local goingSpeed = math.floor(speed - maxSpeed)
                        local occupants = getVehicleOccupants(veh)
                        local beltMiss = false
                        for k,v in pairs(occupants) do
                            if v.type == "player" then
                                if veh and getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck" then
                                    if not getElementData(v, "char >> belt") then
                                        beltMiss = true
                                        break
                                    end
                                end 
                            end
                        end
                        
                        if not ignoreModel[model] then
                            if beltMiss then
                                ticket = ticket + noBeltTicket
                                outputChatBox(syntax .. "Átlépted a sebességhatárt és valakinek a járművedben nem volt bekötve a biztonsági öve ezért " .. green .. "$ " .. ticket .. white .. " bírságot kaptál.",255,255,255,true)
                                outputChatBox(syntax .. "Megengedett: "..green..maxSpeed..white.." km/h | Te sebességed: "..green..speed..white.." km/h | Átlépés mértéke: "..green..goingSpeed..white.." km/h",255,255,255,true)
                            else
                                outputChatBox(syntax .. "Átlépted a sebességhatárt ezért " .. green .. "$ " .. ticket .. white .. " bírságot kaptál.",255,255,255,true)
                                outputChatBox(syntax .. "Megengedett: "..green..maxSpeed..white.." km/h | Te sebességed: "..green..speed..white.." km/h | Átlépés mértéke: "..green..goingSpeed..white.." km/h",255,255,255,true)
                            end

                            spam = getTickCount()
                            playSound("files/shutter.mp3")
                            takeMoney(localPlayer, ticket)
                            fadeCamera(false, 0.5, 255,255,255)
							createEffect("camflash", traffiPos[colshapeID][1],traffiPos[colshapeID][2],traffiPos[colshapeID][3]+0.5)	
                            setTimer(
                                function()
                                    fadeCamera(true, 0.5, 255,255,255)
                                end, 700, 1
                            )

                            triggerLatentServerEvent("speedcams.checkWantedVehicle", 5000, false, localPlayer, veh)
                        end
                    else
                        local ticket = noBeltTicket
                        local occupants = getVehicleOccupants(veh)
                        local beltMiss = false
                        for k,v in pairs(occupants) do
                            if v.type == "player" then
                                if veh and getVehicleType(veh) == "Automobile" or getVehicleType(veh) == "Plane" or getVehicleType(veh) == "Monster Truck" then
                                    if not getElementData(v, "char >> belt") then
                                        beltMiss = true
                                        break
                                    end
                                end 
                            end
                        end
                        
                        if not ignoreModel[model] then
                            if beltMiss then
                                playSound("files/shutter.mp3")
                                outputChatBox(syntax .. "A járművedben egy vagy több személynek nem volt bekötve a biztonsági öve ezért ".. green .. "$ " .. ticket .. white .. " bírságot kaptál.",255,255,255,true)
                                takeMoney(localPlayer, ticket)
                                spam = getTickCount()
								createEffect("camflash", traffiPos[colshapeID][1],traffiPos[colshapeID][2],traffiPos[colshapeID][3]+0.5)	
                                fadeCamera(false, 0.5, 255,255,255)
                                setTimer(
                                    function()
                                        fadeCamera(true, 0.5, 255,255,255)
                                    end, 700, 1
                                )

                                triggerLatentServerEvent("speedcams.checkWantedVehicle", 5000, false, localPlayer, veh)
                            end
                        end 
                    end
                end
            end
        end
    end
)

function getElementSpeed( element, unit )
    if isElement( element ) then
        local x,y,z = getElementVelocity( element )
        if unit == "mph" or unit == 1 or unit == "1" then
			local vx, vy, vz = getElementVelocity(element)
	    	return math.sqrt(vx^2 + vy^2 + vz^2) * 187.5
        else
			local vx, vy, vz = getElementVelocity(element)
	    	return math.sqrt(vx^2 + vy^2 + vz^2) * 187.5
        end
    else
        outputDebugString( "Not an element. Can't get speed" )
        return false
    end
end

function takeMoney(e, m)
    triggerLatentServerEvent("giveMoneyToFaction", 5000, false, localPlayer, localPlayer, 1, math.floor(m * 0.05)) -- MEDIC MONEY GIVING
    exports['cr_core']:takeMoney(e, m, nil, true)
end

local blipCache = {}
local factionCheckTimer = false
local oldFactions = {}

function onClientStart()
    if isTimer(factionCheckTimer) then 
        killTimer(factionCheckTimer)
        factionCheckTimer = nil
    end

    factionCheckTimer = setTimer(
        function()
            local resource = getResourceFromName("cr_dashboard")
            
            if resource and getResourceState(resource) == "running" then 
                local currentFactions = exports.cr_dashboard:getPlayerFactions(localPlayer)

                if #oldFactions ~= #currentFactions then 
                    oldFactions = currentFactions

                    destroyAllWantedBlip()
                end
            end
        end, 1000, 0
    )
end
addEventHandler("onClientResourceStart", resourceRoot, onClientStart)

function deleteWantedBlip(veh)
    if blipCache[veh] then 
        exports.cr_radar:destroyStayBlip(blipCache[veh].blipName)

        if isTimer(blipCache[veh].theTimer) then 
            killTimer(blipCache[veh].theTimer)
            blipCache[veh].theTimer = nil
        end

        blipCache[veh] = nil
    end
end

function destroyAllWantedBlip()
    for k, v in pairs(blipCache) do 
        deleteWantedBlip(k)
    end

    blipCache = {}
end

function createWantedBlip(thePlayer, veh)
    if not blipCache[veh] then 
        local plateText = veh.plateText
        local blipElement = Blip(veh.position, 0, 2, 255, 0, 0, 255, 0, 0)
        local blipName = "Körözött jármű - " .. plateText

        blipElement:attach(veh)

        local redR, redG, redB = exports.cr_core:getServerColor("red", false)
        local radarBlip = exports.cr_radar:createStayBlip(blipName, blipElement, 0, "target", 24, 24, redR, redG, redB)
        local theTimer = setTimer(deleteWantedBlip, 5000, 1, veh)

        blipCache[veh] = {blipName = blipName, theTimer = theTimer}
    end
end

function onClientElementDestroy()
    if blipCache[source] then 
        deleteWantedBlip(source)
    end
end
addEventHandler("onClientElementDestroy", root, onClientElementDestroy)

function onWantedBlipCreate(veh)
    if isElement(source) and isElement(veh) then 
        if exports.cr_dashboard:isPlayerInFaction(localPlayer, 1) then 
            createWantedBlip(source, veh)
        end
    end
end
addEvent("speedcams.onWantedBlipCreate", true)
addEventHandler("speedcams.onWantedBlipCreate", root, onWantedBlipCreate)
