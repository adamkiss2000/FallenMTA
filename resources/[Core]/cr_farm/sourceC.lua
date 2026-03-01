local screenX, screenY = guiGetScreenSize()
local renderTarget = dxCreateRenderTarget(128*5, 128*10)
local boardTarget = {}
local boardShader = {}
local boardText = ""

local lastClickTick = 0

local wateringTick = 0
local wateringState = false
local wateringSlot = 0

local alreadyWatering = false

local changingTick = 0
local changingState = false
local changingSlot = 0
local changingClone = ""
local changingAlpha = 0
local changingProcess = 10
local changeValue = 0
local createdFarmModels = {}
local effectElement = {}

removeWorldModel(3574, 9999, 0, 0, 0)

local alpha = 0

local selectedPlant = 0
local selectedSeed = 0
local selectedRow = 0
local selectedColumn = 0
local surfaceX, surfaceY = 0,0
local farmMarker = nil

local impact = dxCreateFont("files/fonts/impact.ttf", 10, false)
local impact12 = dxCreateFont("files/fonts/impact.ttf", 12)
local impact17 = dxCreateFont("files/fonts/impact.ttf", 17, false)
local impact9 = dxCreateFont("files/fonts/impact.ttf", 9)
local Roboto10 = dxCreateFont("files/fonts/Roboto.ttf", 10)
local Roboto11 = dxCreateFont("files/fonts/Roboto.ttf", 11)
local Roboto = dxCreateFont("files/fonts/Roboto.ttf", 12)
local RobotoBold = dxCreateFont("files/fonts/Roboto.ttf", 17, true)
local Roboto14 = dxCreateFont("files/fonts/Roboto.ttf", 14)
local Roboto17 = dxCreateFont("files/fonts/Roboto.ttf", 17)

local waterLevelIcon = dxCreateTexture("files/water.png")

local infoW, infoH = 190, 70
local hitPosZ = 0
local statusText = ""

local blockTable = {}

local permissionKey = 0
local permissionSelected = ""
local permissionTable = {}

local lastChangeCursorState = 0
local cursorState = false
local renderData = {
	plantState = false,
	maxSeedShow = 4,
	scrollNum = 0,
	farmInterior = false,
	farmDimension = 0,
	interiorW = 300,
	interiorH = 60,
	invitingText = "",
	actualEditing = "",
	memberNameEdit = "",
	permissionState = false,
	newMemberState = false,
}

renderData.interiorX = screenX/2-renderData.interiorW/2
renderData.interiorY = screenY/2-renderData.interiorH/2

local notificationData = {}
local clickedTool = nil
local soundEffects = {}

local activeDirectX = false
local lastActiveDirectX = false

setElementData(localPlayer, "farm:hoe", false)
setElementData(localPlayer, "farm:spade", false)
setElementData(localPlayer, "farm:wateringCan", false)
setElementData(localPlayer, "isPlayerWorking", false)

local modelTable = {
	{"files/models/inti_kicsi", "files/models/hoe", 16672},
	{"files/models/inti_kicsi", "files/models/shovel", 1901},
	{"files/models/inti_kicsi", "files/models/watercan", 16191},
	{"files/models/carrot", "files/models/carrot", 16192},
	{"files/models/radish", "files/models/radish", 16193},
	{"files/models/inti_kicsi", "files/models/int_kicsi", 16671},
	{"files/models/inti_kicsi", "files/models/exterior_1", 16673},
	{"files/models/inti_kicsi", "files/models/board", 16674},
	{"files/models/parsley", "files/models/parsley", 16675},
	{"files/models/onion", "files/models/onion", 16134},
}


addEventHandler("onClientElementDataChange", getRootElement(), function(theKey, oldValue, newValue)
	if source == localPlayer then
		if theKey == "farm:wateringCan" then
			triggerServerEvent("createFarmItemServer", localPlayer, localPlayer, "waterCan", clickedTool, newValue)
		elseif theKey == "farm:hoe" then
			triggerServerEvent("createFarmItemServer", localPlayer, localPlayer, "hoe", clickedTool, newValue)
		elseif theKey == "farm:spade" then
			triggerServerEvent("createFarmItemServer", localPlayer, localPlayer, "spade", clickedTool, newValue)
		end
	end
end)


local maximumLetter = 22
addEventHandler('onClientCharacter', getRootElement(), function(character)
  if renderData.actualEditing == "farm:board" then
    maximumLetter = 22
	elseif renderData.actualEditing == "newMemberName" then
		maximumLetter = 27
	end
	if renderData.actualEditing ~= "" then
		if (utf8.len(renderData.invitingText) < maximumLetter) then
			renderData.invitingText = renderData.invitingText .. character
		end
	end
end)

addEventHandler("onClientKey", getRootElement(), function(button, state)
	if renderData.actualEditing ~= "" then
		cancelEvent()
		if button == "backspace" and state then
			cancelEvent()
			if utf8.len(renderData.invitingText) >= 1 then
				renderData.invitingText = utf8.sub(renderData.invitingText, 1, utf8.len(renderData.invitingText)-1)
			end
		end
	end
end)


local obj = createObject(16134, -43.5068359375, -371.7939453125, 6.3297071456909)
setElementDoubleSided(obj, true)

function generateDefaultBlockTable()
	local defaultBlockTable = {}
	local row, column = 0, 0
	for i = 1, 50 do
		if column ~= 5 then
			column = column + 1
		end

		if column == 3 then
			table.insert(defaultBlockTable, {
				state = false,
				newStateLevel = 0,
				newStateSaveLevel = 0,
				changingTick = 0,
				changingState = false,
				changingSlot = 0,
				changingValue = 0,
				changingTime = 0,
				waterLevel = 0,
				waterChanger = 0,
				wateringState = false,
				wateringTick = 0,
				waterLossTime = waterLosingTime,
				plantHealth = 100,
				healthRemainingTime = healthTime,
				healthTick = 0,
				blockRow = row,
				blockColumn = column,
			})
		else
			table.insert(defaultBlockTable, {
				state = "land",
				newState = false,
				newStateLevel = 0,
				newStateSaveLevel = 0,
				changingTick = 0,
				changingState = false,
				changingSlot = 0,
				changingValue = 0,
				changingTime = 0,

				plantObject = 0,
				plantTimer = growingTime,
				plantSize = 0,
				plantFullSize = 1,
				plantTick = 0,
				plantIndex = 0,
				plantHealth = 100,
				plantHelathChanger = 100,
				healthRemainingTime = healthTime,
				healthTick = 0,
				sizeChanger = 0,

				waterLevel = 0,
				waterChanger = 0,
				wateringState = false,
				wateringTick = 0,
				waterLossTick = 0,
				waterLossTime = waterLosingTime,
	
				blockRow = row,
				blockColumn = column,
			})
		end

		if column == 5 then
			column = 0
			row = row + 1
		end
	end
	return defaultBlockTable
end


addEventHandler("onClientRender", getRootElement(), function()
	if not renderData.farmInterior then
		return
	end

	lastActiveDirectX = activeDirectX
	activeDirectX = false
	local time = getTickCount() - lastChangeCursorState
	if time >= 500 then
		cursorState = not cursorState
		lastChangeCursorState = getTickCount()
	end

	for k, v in pairs(blockTable[renderData.farmDimension]) do
		if isElement(v.plantObject) and v.plantTick > 0 and v.waterLevel < 20 then
			dxDrawImageOnElement({worldX+(v.blockColumn-1)+0.5, worldY+v.blockRow+0.5, 4.8}, waterLevelIcon, 1000, 0.9, 0.2, 104,170,249)
		end

		if v.wateringState then
			local currentTick = getTickCount()
			local progress = (currentTick-v.wateringTick)/wateringTime
			v.waterLevel = interpolateBetween(v.waterChanger, 0, 0, 100, 0, 0, progress, "Linear")
			if progress > 1 then
				v.wateringState = false
			end
		else
			if v.waterLevel > 0 then
				local currentTick = getTickCount()
				local progress = (currentTick-v.waterLossTick)/v.waterLossTime
				v.waterLevel = interpolateBetween(v.waterChanger, 0, 0, 0, 0, 0, progress, "Linear")
				if math.ceil(v.waterLevel) == 19 then
					v.healthTick = getTickCount()
				end
			end
		end

		if v.waterLevel > 20 then
			v.plantHelathChanger = v.plantHealth
		end
		if isElement(v.plantObject) and v.waterLevel < 20 then
			local currentTick = getTickCount()
			local progress = (currentTick-v.healthTick)/v.healthRemainingTime
			v.plantHealth = interpolateBetween(v.plantHelathChanger, 0, 0, 0, 0, 0, progress, "Linear")
		end

		if v.changingState then
			local currentTick = getTickCount()
			local progress = (currentTick-v.changingTick)/v.changingTime
			v.newStateLevel = interpolateBetween(v.newStateSaveLevel, 0, 0, v.changingValue, 0, 0, progress, "Linear")
			if v.newStateLevel >= v.changingValue then
				v.changingState = false
			end
			if v.newStateLevel >= 100 then
				v.state = v.newState
				v.newState = false
				v.newStateLevel = 0
			end
		end

		if isElement(v.plantObject) and v.plantTick > 0 then
			local currentTick2 = getTickCount()
			local growingProgress = (currentTick2-v.plantTick) / v.plantTimer
			v.sizeChanger = interpolateBetween(v.plantSize, 0, 0, v.plantFullSize, 0, 0, growingProgress, "Linear")
			setObjectScale(v.plantObject, v.sizeChanger)
			if seedTable[v.plantIndex].growZ then
				local x,y,z = getElementPosition(v.plantObject)
				local plusZ = v.sizeChanger * (seedTable[v.plantIndex].growZ)
				setElementPosition(v.plantObject, x,y,4.45+seedTable[v.plantIndex].zCorrection+plusZ)
			end
		end
	end

	dxSetRenderTarget(renderTarget, true)
		for k, v in pairs(blockTable[renderData.farmDimension]) do
			if v.blockColumn ~= 3 then
				if v.waterLevel < 100 then
					if v.state then
						dxDrawImage((v.blockColumn-1)*128,v.blockRow*128,128, 128,"files/"..v.state..".png")
					end
					if v.newState then
						dxDrawImage((v.blockColumn-1)*128,v.blockRow*128,128, 128,"files/"..v.newState..".png", 0,0,0, tocolor(255,255,255,255 * (v.newStateLevel/100)))
					end
				end
			else
				dxDrawImage((v.blockColumn-1)*128,v.blockRow*128,128, 128,"files/land.png")
			end
		end

		for k, v in pairs(blockTable[renderData.farmDimension]) do
			if v.blockColumn ~= 3 then
				if v.state then
					if v.waterLevel > 0 then
						dxDrawImage((v.blockColumn-1)*128-64,v.blockRow*128-64,256, 256,"files/"..v.state.."_wet.png",0,0,0,tocolor(255,255,255,255 * (v.waterLevel/100)))
						dxDrawImage((v.blockColumn-1)*128-64,v.blockRow*128-64,256, 256,"files/wet.png",0,0,0,tocolor(255,255,255,255 * (v.waterLevel/400)))
						if v.newState then
							dxDrawImage((v.blockColumn-1)*128-64,v.blockRow*128-64,256, 256,"files/"..v.newState.."_wet.png", 0,0,0, tocolor(255,255,255,255 * (v.newStateLevel/100)))
						end
					end
				end
			end
		end

		for k, v in pairs(blockTable[renderData.farmDimension]) do
			if v.blockColumn == 3 then
				dxDrawImage((v.blockColumn-1)*128,v.blockRow*128,128, 128,"files/road.png")
			end
			if selectedPlant == k then
				if isCursorShowing() then
					dxDrawImage((v.blockColumn-1)*128,v.blockRow*128,128, 128,"files/selection.png")
				end
			end
		end
	dxSetRenderTarget()

	if not farmMarker then
		return
	end

	if getElementData(localPlayer, characterIDElementData) == getElementData(farmMarker, "farm:owner") then
		local manageX, manageY = getScreenFromWorldPosition(-21.083984375, -367.43768310547, 5.8471306800842)
		if manageX and manageY then
			local localX, localY, localZ = getElementPosition(localPlayer)
			local distance = getDistanceBetweenPoints3D(-21.083984375, -367.43768310547, 6.4471306800842, localX, localY, localZ)

			if distance < 3 then
				local distMul = 1 - distance / 30
				local alphaMul = 1 - distance / 5
				boardText = getElementData(farmMarker, "farm:name")
				local cursorTickCorrectY = 0

				if not renderData.permissionState then
					local sx = 150 * distMul
					local sy = 30 * distMul
					local x = manageX - sx / 2
					local y = manageY - sy / 2

					if renderData.actualEditing == "farm:board" then
						boardText = utf8.gsub(utf8.upper(renderData.invitingText), "_", " ")
						changeNameButtonText = getTranslatedText("changeFarmName_button")
						if cursorState then
							local w = dxGetTextWidth(renderData.invitingText, distMul * 0.8, RobotoBold)
							if utf8.len(boardText) >= 11 then
								cursorTickCorrectY = 23
								w = dxGetTextWidth(utf8.sub(renderData.invitingText, 12, utf8.len(boardText)), distMul * 0.8, RobotoBold)
							end
							dxDrawLine(x+80+w/2, y + (24) * distMul+35+cursorTickCorrectY, x+80+w/2, y + (24) * distMul+55+cursorTickCorrectY, tocolor(255, 255, 255, 255), 1, true)
						end
					else
						changeNameButtonText = getTranslatedText("editFarmName_button")
					end
					if not string.find(boardText, "\n") then
						if utf8.len(boardText) >= 11 then
							boardText = utf8.sub(boardText, 1, 11).."/xentx/"..utf8.sub(boardText, 12, utf8.len(boardText))
						end
						boardText = boardText:gsub("/xentx/", "\n")
					end
					dxDrawRectangle(x, y + (24) * distMul, 150, 150, tocolor(0,0,0,160))
					dxDrawText(getTranslatedText("farmManagementTitle"), x, y + (24) * distMul, x + sx+10, y + (24) * distMul+25, tocolor(255, 255, 255, 255 * alphaMul), distMul * 0.9, Roboto, "center", "center")
					dxDrawText(utf8.gsub(utf8.upper(boardText), "_", " "), x, y + (24) * distMul+35, x + sx+10, y + (24) * distMul+55, tocolor(255, 255, 255, 255 * alphaMul), distMul * 0.8, RobotoBold, "center", "top")
					dxDrawButtonWithText(x+5, y + (24) * distMul + 125, 140, 20, tocolor(124, 197, 118, 150), tocolor(124, 197, 118, 240), getTranslatedText("permission_button"), tocolor(0,0,0,255), 1, Roboto10, "center", "center", "permissionButton")
					dxDrawButtonWithText(x+5, y + (24) * distMul + 100, 140, 20, tocolor(124, 197, 118, 150), tocolor(124, 197, 118, 240), changeNameButtonText, tocolor(0,0,0,255), 1, Roboto10, "center", "center", "editFarmName")
				else
					local sx = 300 * distMul
					local sy = 25 * distMul
					local x = manageX - sx / 2
					local y = manageY - sy / 2
					local plusPermissionWidth = #permissionTable * 25
					permissionSelected = ""
					permissionKey = 0
					dxDrawRectangle(x, y + (24) * distMul, 300, 25, tocolor(0,0,0,210))
					dxDrawText(getTranslatedText("permission_button"), x, y + (24) * distMul, x + sx+10, y + (24) * distMul+25, tocolor(255, 255, 255, 255 * alphaMul), distMul * 0.9, Roboto14, "center", "center")
					if renderData.actualEditing == "" then
						dxDrawRectangle(x, y + (24) * distMul+25, 300, 25+plusPermissionWidth, tocolor(0,0,0,130))
						dxDrawButtonWithText(x+3, y + (24) * distMul + 27+plusPermissionWidth, 130, 20, tocolor(124, 197, 118, 150), tocolor(124, 197, 118, 240), getTranslatedText("permission_addNewMember"), tocolor(0,0,0,255), 1, Roboto10, "center", "center", "newMemberButton")
						dxDrawButtonWithText(x+237, y + (24) * distMul + 27+plusPermissionWidth, 60, 20, tocolor(124, 197, 118, 150), tocolor(124, 197, 118, 240), getTranslatedText("permission_save"), tocolor(0,0,0,255), 1, Roboto10, "center", "center", "closePermission")
						for k, v in pairs(permissionTable) do
							dxDrawText(v.playerName, x+5, y + (24) * distMul + 23 + (k*25)-25, x + sx+10, y + (24) * distMul+50 + (k*25)-25, tocolor(255, 255, 255, 255 * alphaMul), distMul * 0.9, Roboto10, "left", "center")
							local counter = 0
							for permK, permV in pairs(v.permissions) do
								counter = counter + 1
								if isCursorInBox(x+150+(counter-1)*25, y + (24) * distMul + 23 + (k*25)-25, 25, 25) then
									permissionKey = k
									permissionSelected = permK
								end
								dxDrawTick(x+150+(counter-1)*25, y + (24) * distMul + 23 + (k*25)-25, permV, permissionMenu[counter])
							end
						end
					else
						dxDrawRectangle(x, y + (24) * distMul+25, 300, 25, tocolor(0,0,0,130))
						renderData.memberNameEdit = renderData.invitingText
						if cursorState then
							local w = dxGetTextWidth(renderData.invitingText, distMul * 0.9, Roboto10)
							dxDrawLine(x+8+w, y + (24) * distMul+28, x+8+w, y + (24) * distMul+45, tocolor(255, 255, 255, 255), 1, true)
						end
						dxDrawText(renderData.memberNameEdit, x+5, y + (24) * distMul + 23, x + sx+10, y + (24) * distMul+50, tocolor(255, 255, 255, 255 * alphaMul), distMul * 0.9, Roboto10, "left", "center")
						dxDrawButtonWithText(x+237, y + (24) * distMul + 27, 60, 20, tocolor(124, 197, 118, 150), tocolor(124, 197, 118, 240), getTranslatedText("permission_add"), tocolor(0,0,0,255), 1, Roboto10, "center", "center", "addMemberDone")
					end
				end
			end
		end
	end

	local localX, localY, localZ = getElementPosition(localPlayer)
	local objects = getElementsByType("object", getRootElement(), true)
	if #objects > 0 then
		for i = 1, #objects do
			local object = objects[i]

			if isElement(object) and isElementStreamable(object) then
				if getElementData(object, "farm:spadeObject") or getElementData(object, "farm:hoeObject") or getElementData(object, "farm:waterCanObject") then
					local objX, objY, objZ = getElementPosition(object)
					objZ = objZ + 0.3
					--objY = objY - 0.3
					if getElementData(object, "farm:hoeObject") then
						objZ = objZ + 0.6
						--objY = objY + 0.6
					elseif getElementData(object, "farm:waterCanObject") then
						objZ = objZ + 0.2
						--objY = objY + 0.3
					end
					if isLineOfSightClear(objX, objY, objZ, localX, localY, localZ, false, false, false, false, false, false, false, localPlayer) then
						local screenX, screenY = getScreenFromWorldPosition(objX, objY, objZ + 0.5)


						if screenX and screenY then
							local distance = getDistanceBetweenPoints3D(objX, objY, objZ, localX, localY, localZ)

							if distance < 3 then
								local distMul = 1 - distance / 40
								local alphaMul = 1 - distance / 5

								local sx = 100 * distMul
								local sy = 40 * distMul
								local x = screenX - sx / 2
								local y = screenY - sy / 2
								local text = ""
								local numberOfObject = 0
								dxDrawRectangle(x, y + (24) * distMul, 100, 40, tocolor(0,0,0,180))
								dxDrawRectangle(x, y + (24) * distMul, 100, 20, tocolor(0,0,0,180))
								if getElementData(object, "farm:hoeObject") then
									text = getTranslatedText("tools_hoe")
									numberOfObject = getElementData(object, "farm:hoeObjectNumber")
								elseif getElementData(object, "farm:waterCanObject") then
									text = getTranslatedText("tools_wateringCan")
									numberOfObject = getElementData(object, "farm:waterCanObjectNumber")
								else
									text = getTranslatedText("tools_shovel")
									numberOfObject = getElementData(object, "farm:spadeObjectNumber")
								end
								dxDrawText("#7cc576" .. text, x, y + (24) * distMul, x + sx, 0, tocolor(255, 255, 255, 255 * alphaMul), distMul * 1, Roboto, "center", "top", false, false, false, true)
								dxDrawText(numberOfObject.." "..getTranslatedText("piecesShortly"), x, y + (45) * distMul, x + sx, 0, tocolor(255, 255, 255, 255 * alphaMul), distMul * 1, Roboto, "center", "top", false, false, false, true)
							end
						end
					end
				end
			end
		end
	end

	if isCursorShowing() then
		local relativeX, relativeY = getCursorPosition()
		local cursorX, cursorY = relativeX * screenX, relativeY * screenY
		local cameraPosX, cameraPosY, cameraPosZ = getCameraMatrix()
		local cursorWorldPosX, cursorWorldPosY, cursorWorldPosZ = getWorldFromScreenPosition(cursorX, cursorY, 1000)
		local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ = processLineOfSight(cameraPosX, cameraPosY, cameraPosZ, cursorWorldPosX, cursorWorldPosY, cursorWorldPosZ, true, true, true, true, true, true, false, true, localPlayer)
		local row, column = 0, 0
		selectedPlant = 0
		hitPosZ = hitZ

		for i = 1, 50 do
			if column ~= 5 then
				column = column + 1
			end

			if column ~= 3 then
				if isCursorInterSect3D(hitX, hitY, worldX+(column-1), worldY+row, 1, 1) then
					selectedPlant = i
					activeDirectX = selectedPlant
				 	selectedRow = row
					selectedColumn = column
					surfaceX, surfaceY = getScreenFromWorldPosition(worldX+(column-1)+0.5, worldY+row+0.5, hitZ)
					if surfaceX and surfaceY then
						if not renderData.plantState then
							dxDrawRectangle(surfaceX-infoW/2, surfaceY-infoH/2, infoW, infoH, tocolor(0,0,0,200))
							dxDrawText(getTranslatedText("ground_wateringLevel"), surfaceX-infoW/2, surfaceY-infoH/2+5, surfaceX+infoW/2, 0, white, 1, Roboto10, "center", "top")
							dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+28, infoW-20, 13, tocolor(255,255,255,30))
							dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+28, (infoW-20)*blockTable[renderData.farmDimension][i].waterLevel/100, 13, tocolor(104,170,249,255))
							if infoH == 175 then
								dxDrawText(getTranslatedText("ground_state").." "..statusText, surfaceX-infoW/2, surfaceY-95/2+47, surfaceX+infoW/2, 0, white, 1, Roboto10, "center", "top")
							else
								dxDrawText(getTranslatedText("ground_state").." "..statusText, surfaceX-infoW/2, surfaceY-infoH/2+47, surfaceX+infoW/2, 0, white, 1, Roboto10, "center", "top")
							end
							if blockTable[renderData.farmDimension][selectedPlant].newState == "land_cultivated" then
								infoH = 90
								dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+70, infoW-20, 13, tocolor(124, 197, 118, 80))
								dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+70, (infoW-20)*blockTable[renderData.farmDimension][i].newStateLevel/100, 13, tocolor(124, 197, 118, 240))
								statusText = getTranslatedText("ground_cultivating")
							elseif blockTable[renderData.farmDimension][selectedPlant].newState == "land_planted" then
								infoH = 90
								dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+70, infoW-20, 13, tocolor(124, 197, 118, 80))
								dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+70, (infoW-20)*blockTable[renderData.farmDimension][i].newStateLevel/100, 13, tocolor(124, 197, 118, 240))
								statusText = getTranslatedText("ground_planting")
							elseif blockTable[renderData.farmDimension][selectedPlant].state == "land_planted" then
								infoH = 175
								statusText = ""

								local healthW = (infoW-20) * blockTable[renderData.farmDimension][selectedPlant].plantHealth / 100
								dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+110, (infoW-20), 13, tocolor(255,255,255,30))
								dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+110, healthW, 13, tocolor(186,184,106,255))

								dxDrawRectangle(surfaceX-infoW/2, surfaceY-infoH/2-25, infoW, 25, tocolor(0,0,0,255))
								dxDrawText("#7cc576" .. seedTable[blockTable[renderData.farmDimension][selectedPlant].plantIndex].name, surfaceX-infoW/2, surfaceY-infoH/2-25, surfaceX-infoW/2+infoW, surfaceY-infoH/2, white, 1, Roboto10, "center", "center", false, false, false, true)

								dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+70, (infoW-20), 13, tocolor(255,255,255,30))
								dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+70, (infoW-20)*blockTable[renderData.farmDimension][i].sizeChanger, 13, tocolor(124, 197, 118, 240))
								dxDrawText(getTranslatedText("ground_growing"), surfaceX-infoW/2, surfaceY-infoH/2+47, surfaceX+infoW/2, 0, white, 1, Roboto10, "center", "top")

								dxDrawButtonWithText(surfaceX-infoW/2+5, surfaceY-infoH/2+148, (infoW-10), 20, tocolor(124, 197, 118, 150), tocolor(124, 197, 118, 240), getTranslatedText("harvest_button"), tocolor(0,0,0,255), 1, Roboto10, "center", "center")
							elseif blockTable[renderData.farmDimension][selectedPlant].newState == "land_hole" then
								infoH = 90
								dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+70, infoW-20, 13, tocolor(124, 197, 118, 80))
								dxDrawRectangle(surfaceX-infoW/2+10, surfaceY-infoH/2+70, (infoW-20)*blockTable[renderData.farmDimension][i].newStateLevel/100, 13, tocolor(124, 197, 118, 240))
								statusText = getTranslatedText("ground_digging")
							elseif blockTable[renderData.farmDimension][selectedPlant].state == "land_cultivated" then
								statusText = getTranslatedText("ground_cultivated")
								infoH = 70
							elseif blockTable[renderData.farmDimension][selectedPlant].state == "land_hole" then
								infoH = 120
								statusText = getTranslatedText("ground_readyForPlanting")
								dxDrawButtonWithText(surfaceX-infoW/2+5, surfaceY-infoH/2+70, (infoW-10), 20, tocolor(124, 197, 118, 150), tocolor(124, 197, 118, 240), getTranslatedText("ground_fillTheHole"), tocolor(0,0,0,255), 1, Roboto10, "center", "center")
								dxDrawButtonWithText(surfaceX-infoW/2+5, surfaceY-infoH/2+95, (infoW-10), 20, tocolor(124, 197, 118, 150), tocolor(124, 197, 118, 240), getTranslatedText("ground_plantTheSeed"), tocolor(0,0,0,255), 1, Roboto10, "center", "center")
							else
								statusText = getTranslatedText("ground_uncultivated")
								infoH = 70
							end
						else

							local width, height = 190, 20 * #seedTable + 5
							local counter = 0
							dxDrawRectangle(surfaceX-width/2, surfaceY-height/2, width, height, tocolor(0, 0, 0, 180))
							--dxDrawText(getTranslatedText("ground_seedMenu"), surfaceX-width/2+10, surfaceY-height/2+7, surfaceX+width/2, 0, white, 1, Roboto, "left", "top")
							--dxDrawImageButton(surfaceX+width/2-23, surfaceY-height/2+12, 12, 12, "files/close.png", tocolor(255,255,255,255), tocolor(231, 56, 56, 255))
							selectedSeed = 0
							for k, v in pairs(seedTable) do
								--if (k > renderData.scrollNum and counter < renderData.maxSeedShow) then
									counter = counter + 1
									if isCursorInBox(surfaceX - width / 2 + 10, surfaceY - height / 2 + 5 + (counter - 1) * 20, width - 20, 20) then
										selectedSeed = k
										if hasPlayerItem(localPlayer, seedTable[k].seedID) then
											drawCenterText(v.name, surfaceX - width / 2 + 10, surfaceY - height / 2 + 5 + (counter - 1) * 20, width - 20, 20, tocolor(124, 197, 118, 240), 0.9, Roboto10)
										else
											drawCenterText(v.name, surfaceX - width / 2 + 10, surfaceY - height / 2 + 5 + (counter - 1) * 20, width - 20, 20, tocolor(124, 197, 118, 240), 0.9, Roboto10)
										end
									else
										if hasPlayerItem(localPlayer, seedTable[k].seedID) then
											drawCenterText(v.name, surfaceX - width / 2 + 10, surfaceY - height / 2 + 5 + (counter - 1) * 20, width - 20, 20, tocolor(255, 255, 255, 255), 0.9, Roboto10)
										else
											drawCenterText(v.name, surfaceX - width / 2 + 10, surfaceY - height / 2 + 5 + (counter - 1) * 20, width - 20, 20, tocolor(255, 255, 255, 180), 0.9, Roboto10)
										end
									end

									if k == #seedTable then
										counter = counter + 1
										if isCursorInBox(surfaceX - width / 2 + 10, surfaceY - height / 2 + 5 + (counter - 1) * 20, width - 20, 20) then
											dxDrawRectangle(surfaceX - width / 2, surfaceY - height / 2 + 5 + (counter - 1) * 20, width, 20, tocolor(215, 89, 89, 240))
											if getKeyState("mouse1") then
												renderData.plantState = false
											end
										else
											dxDrawRectangle(surfaceX - width / 2, surfaceY - height / 2 + 5 + (counter - 1) * 20, width, 20, tocolor(215, 89, 89, 150))
										end
										drawCenterText("Mégsem", surfaceX - width / 2 + 10, surfaceY - height / 2 + 5 + (counter - 1) * 20, width - 20, 20, tocolor(255, 255, 255, 180), 0.9, Roboto10)
									end

									--dxDrawButtonWithText(surfaceX-width/2+10, surfaceY-height/2+35+(counter-1)*25, width-20, 20, tocolor(50, 50, 50, 255), tocolor(102, 153, 102, 255), v.name, tocolor(255,255,255,255), 1, montSerrat, "left", "center")
									
									--dxDrawImage(surfaceX+width/2-35, surfaceY-height/2+35+(counter-1)*25, 20, 20, "files/seeds/"..v.seedImage..".png")
								--end
							end
							--dxDrawScrollBar(surfaceX+width/2-5, surfaceY-height/2+35, 2, 95, #seedTable, renderData.maxSeedShow, renderData.scrollNum, tocolor(50, 50, 50, 255), tocolor(102, 153, 102, 255))
						end
					end
				end
			end

			if column == 5 then
				column = 0
				row = row + 1
			end

		end
		if activeDirectX ~= lastActiveDirectX and activeDirectX then
			renderData.plantState = false
		end
	end
  dxDrawImage3D(worldX, worldY, 4.45, 10, 1, renderTarget, tocolor( 255, 255, 255, 255 ) )
end)

function drawCenterText(text, x, y, w, h, color, size, font)
    dxDrawText(text, x + w / 2 , y + h / 2, x + w / 2, y + h / 2, color, size, font, "center", "center", false, false, false, true)
end

addEventHandler("onClientClick", getRootElement(), function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if button == "left" and state == "down" then
			if not (lastClickTick + 1200 < getTickCount()) then
				return 
			end

			if getElementData(localPlayer, "isPlayerWorking") then
				return
			end

			if clickedElement then
				if activeDirectX == "editFarmName" then
					if renderData.actualEditing ~= "farm:board" then
						renderData.invitingText = getElementData(farmMarker, "farm:name")
						renderData.actualEditing = "farm:board"
					else
						renderData.actualEditing = ""
						triggerServerEvent("changeFarmInteriorName", localPlayer, getElementData(farmMarker, "farm:markerID"), boardText)
					end
				elseif activeDirectX == "permissionButton" then
					if not renderData.permissionState and renderData.actualEditing == "" then
						renderData.permissionState = true
					end
				elseif activeDirectX == "closePermission" then
					if renderData.permissionState and renderData.actualEditing == "" then
						renderData.permissionState = false
						triggerServerEvent("savePermissionTable", localPlayer, localPlayer, renderData.farmDimension, permissionTable)
					end
				elseif activeDirectX == "newMemberButton" then
					if renderData.actualEditing == "" then
						renderData.invitingText = ""
						renderData.actualEditing = "newMemberName"
					end
				elseif activeDirectX == "addMemberDone" then
					local targetPlayer, targetPlayerName = findPlayerByName(localPlayer, renderData.memberNameEdit)
					if targetPlayer then
						table.insert(permissionTable, {
							playerName = targetPlayerName,
							permissions = {
								cultivateState = false,
								diggingState = false,
								wateringState = false,
								plantState = false,
								harvestState = false,
								openState = false,
							}
						})
					end
					renderData.actualEditing = ""
					renderData.memberNameEdit = ""
					triggerServerEvent("savePermissionTable", localPlayer, localPlayer, renderData.farmDimension, permissionTable)
				end

				if permissionKey > 0 and permissionSelected ~= "" then
					permissionTable[permissionKey].permissions[permissionSelected] = not permissionTable[permissionKey].permissions[permissionSelected]
				end

				if getElementData(clickedElement, "farm:spadeObject") then
					if hasPlayerPermission("diggingState") then

						if getElementData(localPlayer, "farm:hoe") then
							outputChatBox(farmPrefix..""..getTranslatedText("chatbox_hoeDown"), 255,255,255, true)
							return
						end

						if not getElementData(localPlayer, "farm:spade") and getElementData(clickedElement, "farm:spadeObjectNumber") > 0 then
							clickedTool = clickedElement
							setElementData(localPlayer, "farm:spade", true)
						else
							clickedTool = clickedElement
							setElementData(localPlayer, "farm:spade", false)
						end
					end
				elseif getElementData(clickedElement, "farm:hoeObject") then
					if hasPlayerPermission("cultivateState") then

						if getElementData(localPlayer, "farm:spade") then
							outputChatBox(farmPrefix..""..getTranslatedText("chatbox_shovelDown"), 255,255,255, true)
							return
						end

						if not getElementData(localPlayer, "farm:hoe") and getElementData(clickedElement, "farm:hoeObjectNumber") > 0 then
							clickedTool = clickedElement
							setElementData(localPlayer, "farm:hoe", true)
						else
							clickedTool = clickedElement
							setElementData(localPlayer, "farm:hoe", false)
						end
					end
				elseif getElementData(clickedElement, "farm:waterCanObject") then
					if hasPlayerPermission("wateringState") then

						if getElementData(localPlayer, "farm:spade") or getElementData(localPlayer, "farm:hoe") then
							outputChatBox(farmPrefix..""..getTranslatedText("chatbox_toolDown"), 255,255,255, true)
							return
						end

						if not getElementData(localPlayer, "farm:wateringCan") and getElementData(clickedElement, "farm:waterCanObjectNumber") > 0 then
							clickedTool = clickedElement
							setElementData(localPlayer, "farm:wateringCan", true)
						else
							clickedTool = clickedElement
							setElementData(localPlayer, "farm:wateringCan", false)
						end
					end
				end
			end
		if selectedPlant > 0 then
			if renderData.plantState then
				local counter = 0
				for k, v in pairs(seedTable) do
					if (k > renderData.scrollNum and counter < renderData.maxSeedShow) then
						counter = counter + 1
					end
				end
			end

			if blockTable[renderData.farmDimension][selectedPlant].state == "land_hole" then
				if isCursorInBox(surfaceX-infoW/2+5, surfaceY-infoH/2+95, (infoW-10), 20) then
					if hasPlayerPermission("plantState") then
						if not renderData.plantState then
							renderData.plantState = true
							return
						end
					end
				elseif isCursorInBox(surfaceX-infoW/2+5, surfaceY-infoH/2+70, (infoW-10), 20) then
					if hasPlayerPermission("digging") then
						if not renderData.plantState then
							if getElementData(localPlayer, "farm:spade") then
								local calculatedRotation = isPlayerFacingToElement(localPlayer)
								if calculatedRotation then
									triggerServerEvent("syncNewSurfaceToServer", localPlayer, selectedPlant, "harvestNoSeed", localPlayer, 0, renderData.farmDimension)
									setElementRotation(localPlayer, 0,0,calculatedRotation)
								end
							end
						end
					end
				end
			elseif blockTable[renderData.farmDimension][selectedPlant].state == "land_planted" then
				if isCursorInBox(surfaceX-infoW/2+5, surfaceY-infoH/2+148, (infoW-10), 20) then
					if hasPlayerPermission("harvestState") then
						if not getElementData(localPlayer, "farm:wateringCan") and not getElementData(localPlayer, "farm:hoe") and not getElementData(localPlayer, "farm:spade") then
							if isElement(blockTable[renderData.farmDimension][selectedPlant].plantObject) and blockTable[renderData.farmDimension][selectedPlant].sizeChanger == blockTable[renderData.farmDimension][selectedPlant].plantFullSize then
								local calculatedRotation = isPlayerFacingToElement(localPlayer)
								if calculatedRotation then
									triggerServerEvent("syncNewSurfaceToServer", localPlayer, selectedPlant, "harvest", localPlayer, 0, renderData.farmDimension)
									setElementRotation(localPlayer, 0,0,calculatedRotation)
								end
							else
								outputChatBox(farmPrefix..""..getTranslatedText("chatbox_tryHarvest"), 255,255,255, true)
							end
						else
							outputChatBox(farmPrefix..""..getTranslatedText("chatbox_toolDown"), 255,255,255, true)
						end
					end
				end
			end

			local calculatedRotation = isPlayerFacingToElement(localPlayer)

			if getElementData(localPlayer, "farm:wateringCan") then
				if calculatedRotation and not alreadyWatering then
					if not blockTable[renderData.farmDimension][selectedPlant].waterState and blockTable[renderData.farmDimension][selectedPlant].waterLevel < 100 then
						triggerServerEvent("syncNewSurfaceToServer", localPlayer, selectedPlant, "watering", localPlayer, 0, renderData.farmDimension)
						setElementRotation(localPlayer, 0,0,calculatedRotation)
						alreadyWatering = true
						setTimer(function()
							alreadyWatering = false
						end, wateringTime, 1)
					end
				end
			end

			if not blockTable[renderData.farmDimension][selectedPlant].changingState then
				if getElementData(localPlayer, "farm:hoe") then
					if calculatedRotation then
						if not blockTable[renderData.farmDimension][selectedPlant].newState or blockTable[renderData.farmDimension][selectedPlant].newState == "land" or blockTable[renderData.farmDimension][selectedPlant].newState == "land_cultivated" then
							if blockTable[renderData.farmDimension][selectedPlant].state ~= "land_cultivated" then
								if not isElement(blockTable[renderData.farmDimension][selectedPlant].plantObject) then
									if blockTable[renderData.farmDimension][selectedPlant].newStateLevel+changingProcess <= 100 then
										triggerServerEvent("syncNewSurfaceToServer", localPlayer, selectedPlant, "cultivate", localPlayer, 0, renderData.farmDimension)
										setElementRotation(localPlayer, 0,0,calculatedRotation)
									end
								else
									outputChatBox(farmPrefix..""..getTranslatedText("chatbox_canNotCultivate"), 255,255,255, true)
								end
							else
								outputChatBox(farmPrefix..""..getTranslatedText("chatbox_alreadyCultivated"), 255,255,255, true)
							end
						end
					end
				end

				if getElementData(localPlayer, "farm:spade") then
					if calculatedRotation then
						if blockTable[renderData.farmDimension][selectedPlant].state == "land_cultivated" then
							triggerServerEvent("syncNewSurfaceToServer", localPlayer, selectedPlant, "digging", localPlayer, 0, renderData.farmDimension)
							setElementRotation(localPlayer, 0,0,calculatedRotation)
						else
							if blockTable[renderData.farmDimension][selectedPlant].state == "land" then 
								outputChatBox(farmPrefix..""..getTranslatedText("chatbox_notEnoughCultivation"), 255,255,255, true)
							end
						end
					end
				end

				if not getElementData(localPlayer, "farm:wateringCan") and not getElementData(localPlayer, "farm:hoe") and not getElementData(localPlayer, "farm:spade") then
					if blockTable[renderData.farmDimension][selectedPlant].state == "land_hole" then
						if renderData.plantState then
							if selectedSeed > 0 then
								if hasPlayerItem(localPlayer, seedTable[selectedSeed].seedID) then
									takeSeedFromPlayer(localPlayer,seedTable[selectedSeed].seedID)
									renderData.plantState = false
									triggerServerEvent("syncNewSurfaceToServer", localPlayer, selectedPlant, "planting", localPlayer, selectedSeed, renderData.farmDimension)
									local calculatedRotation = isPlayerFacingToElement(localPlayer)
									setElementRotation(localPlayer, 0, 0, tonumber(calculatedRotation))
									return
								end
							end
						end
					end
				end
			end
		end
	end
end)

addEvent("syncBlockTableClient", true)
addEventHandler("syncBlockTableClient", getRootElement(), function(player, table, delete, permissions)
	if not delete then
		renderData.farmDimension = getElementDimension(player)
		if table then
			for k, v in pairs(table) do
				if v.plantIndex and v.plantIndex > 0 then
					v.plantObject = createObject(seedTable[v.plantIndex].modelID, worldX+(v.blockColumn-1)+0.5, worldY+v.blockRow+0.5, 4.45+seedTable[v.plantIndex].zCorrection)
					setElementDimension(v.plantObject, renderData.farmDimension)
					v.plantSize = v.sizeChanger
					setObjectScale(v.plantObject, v.sizeChanger)
					v.plantTick = getTickCount()
				end

				if v.waterLevel > 0 or v.waterChanger > 0 then
					v.waterChanger = v.waterLevel
					v.waterLossTick = getTickCount()
				end
				if v.waterLevel < 0 then
					v.waterLevel = 0
					v.waterChanger = 0
				end

				if v.plantIndex and v.plantIndex > 0 and v.plantHealth > 0 then
					v.healthTick = getTickCount()
				end
			end
			blockTable[renderData.farmDimension] = table
		else
			blockTable[renderData.farmDimension] = generateDefaultBlockTable()
		end
		renderData.farmInterior = true

		permissionTable = permissions
	else
		for k, v in pairs(blockTable[renderData.farmDimension]) do
			if isElement(v.plantObject) then
				destroyElement(v.plantObject)
			end
		end
		renderData.farmInterior = false
		blockTable[renderData.farmDimension] = nil

		permissionTable = {}
	end
end)

addEvent("syncNewSurfaceToClient", true)
addEventHandler("syncNewSurfaceToClient", getRootElement(), function(selectedIndex, type, player, plantIndex)
	if fileExists("files/sounds/"..type..".mp3") then
		if isElement(soundEffects[player]) then
			stopSound(soundEffects[player])
		end
		local x,y,z = getElementPosition(player)
		local dimension = getElementDimension(player)
		soundEffects[player] = playSound3D("files/sounds/"..type..".mp3", x,y,z, false)
		setElementDimension(soundEffects[player], dimension)
	end
	if type == "digging" then
		blockTable[renderData.farmDimension][selectedIndex].newStateSaveLevel = blockTable[renderData.farmDimension][selectedIndex].newStateLevel
		blockTable[renderData.farmDimension][selectedIndex].changingTime = diggingTime
		blockTable[renderData.farmDimension][selectedIndex].changingSlot = selctedIndex
		blockTable[renderData.farmDimension][selectedIndex].changingTick = getTickCount()
		blockTable[renderData.farmDimension][selectedIndex].newState = "land_hole"
		blockTable[renderData.farmDimension][selectedIndex].changingValue = 100
		blockTable[renderData.farmDimension][selectedIndex].changingState = true
		setElementData(player, "isPlayerWorking", true)
		setPedAnimation(player, "bomber", "bom_plant_loop", -1, true, false, false)

		setTimer(function()
			setPedAnimation(player)
			setElementData(player, "isPlayerWorking", false)
			blockTable[renderData.farmDimension][selectedIndex].newStateSaveLevel = blockTable[renderData.farmDimension][selectedIndex].newStateLevel
		end, diggingTime, 1)

	elseif type == "cultivate" then
		blockTable[renderData.farmDimension][selectedIndex].newStateSaveLevel = blockTable[renderData.farmDimension][selectedIndex].newStateLevel
		blockTable[renderData.farmDimension][selectedIndex].changingTime = cultivateTime
		blockTable[renderData.farmDimension][selectedIndex].changingSlot = selctedIndex
		blockTable[renderData.farmDimension][selectedIndex].changingTick = getTickCount()
		blockTable[renderData.farmDimension][selectedIndex].newState = "land_cultivated"
		blockTable[renderData.farmDimension][selectedIndex].changingValue = math.floor(blockTable[renderData.farmDimension][selectedIndex].newStateLevel+changingProcess)
		print(blockTable[renderData.farmDimension][selectedIndex].changingValue)
		blockTable[renderData.farmDimension][selectedIndex].changingState = true

		setPedAnimation(player, "baseball", "bat_4", -1, false, false, false)
		setElementData(player, "isPlayerWorking", true)


		setTimer(function()
			setPedAnimation(player)
			setElementData(player, "isPlayerWorking", false)

			blockTable[renderData.farmDimension][selectedIndex].newStateSaveLevel = blockTable[renderData.farmDimension][selectedIndex].newStateLevel
		end, cultivateTime, 1)
	elseif type == "watering" then
		blockTable[renderData.farmDimension][selectedIndex].waterChanger = blockTable[renderData.farmDimension][selectedIndex].waterLevel
		blockTable[renderData.farmDimension][selectedIndex].wateringTick = getTickCount()
		blockTable[renderData.farmDimension][selectedIndex].wateringState = true

		exports.cr_bone_attach:setElementBoneRotationOffset(createdFarmModels[player], 0, -90, 0)
		exports.cr_bone_attach:setElementBonePositionOffset(createdFarmModels[player], 0.2, 0.03, 0.2)
		setPedAnimation(player, "SWORD", "sword_IDLE", -1, true, false, false)
		setElementData(player, "isPlayerWorking", true)

		setTimer(function()
			local playerX, playerY, playerZ = getPedBonePosition(player, 12)
			local pistolPosX, pistolPosY, pistolPosZ = getElementPosition(createdFarmModels[player])
			local pistolRotX, pistolRotY, pistolRotZ = getElementRotation(createdFarmModels[player])
			local angle = math.rad(pistolRotZ + 90 + 180)
			local rotatedX = -math.sin(angle) * 0.4
			local rotatedY = math.cos(angle) * 0.4

			effectElement[player] = createEffect("petrolcan", pistolPosX + rotatedX, pistolPosY + rotatedY, pistolPosZ-0.1, 120, 0, -pistolRotZ - 90 + 180)
			setEffectDensity(effectElement[player], 2)
		end, 500, 1)

		setTimer(function()
			destroyElement(effectElement[player])
			setPedAnimation(player)
			exports.cr_bone_attach:setElementBonePositionOffset(createdFarmModels[player], -0.05, 0.03, 0.3)
			exports.cr_bone_attach:setElementBoneRotationOffset(createdFarmModels[player], 0, -180, 0)
			blockTable[renderData.farmDimension][selectedIndex].waterLossTime = waterLosingTime
			blockTable[renderData.farmDimension][selectedIndex].waterChanger = blockTable[renderData.farmDimension][selectedIndex].waterLevel
			blockTable[renderData.farmDimension][selectedIndex].waterLossTick = getTickCount()
			triggerServerEvent("saveBlockTableActionServer", localPlayer, blockTable[renderData.farmDimension], renderData.farmDimension, selectedIndex, type)

			setElementData(player, "isPlayerWorking", false)
		end, wateringTime, 1)
	elseif type == "planting" then
		blockTable[renderData.farmDimension][selectedIndex].newStateSaveLevel = blockTable[renderData.farmDimension][selectedIndex].newStateLevel
		blockTable[renderData.farmDimension][selectedIndex].healthRemainingTime = healthTime
		blockTable[renderData.farmDimension][selectedIndex].changingTime = plantingTime
		blockTable[renderData.farmDimension][selectedIndex].changingSlot = selctedIndex
		blockTable[renderData.farmDimension][selectedIndex].changingTick = getTickCount()
		blockTable[renderData.farmDimension][selectedIndex].newState = "land_planted"
		blockTable[renderData.farmDimension][selectedIndex].changingValue = 100
		blockTable[renderData.farmDimension][selectedIndex].changingState = true
		blockTable[renderData.farmDimension][selectedIndex].plantIndex = plantIndex

		blockTable[renderData.farmDimension][selectedIndex].plantObject = createObject(seedTable[plantIndex].modelID, worldX+(blockTable[renderData.farmDimension][selectedIndex].blockColumn-1)+0.5, worldY+blockTable[renderData.farmDimension][selectedIndex].blockRow+0.5, 4.45+seedTable[plantIndex].zCorrection)
		setObjectScale(blockTable[renderData.farmDimension][selectedIndex].plantObject, 0)
		setElementDimension(blockTable[renderData.farmDimension][selectedIndex].plantObject, renderData.farmDimension)

		setElementData(player, "isPlayerWorking", true)

		setPedAnimation(player, "bomber", "bom_plant_loop", -1, true, false, false)
		setTimer(function()
			setPedAnimation(player)
			blockTable[renderData.farmDimension][selectedIndex].plantTick = getTickCount()
			blockTable[renderData.farmDimension][selectedIndex].healthTick = getTickCount()
			blockTable[renderData.farmDimension][selectedIndex].newStateSaveLevel = blockTable[renderData.farmDimension][selectedIndex].newStateLevel
			setElementData(player, "isPlayerWorking", false)
			if player == localPlayer then
				triggerServerEvent("saveBlockTableActionServer", localPlayer, blockTable[renderData.farmDimension], renderData.farmDimension, selectedIndex, type)
			end
		end, plantingTime, 1)
	elseif type == "harvest" then
		blockTable[renderData.farmDimension][selectedIndex].newStateSaveLevel = blockTable[renderData.farmDimension][selectedIndex].newStateLevel
		blockTable[renderData.farmDimension][selectedIndex].changingTime = harvestTime
		blockTable[renderData.farmDimension][selectedIndex].changingSlot = selctedIndex
		blockTable[renderData.farmDimension][selectedIndex].changingTick = getTickCount()
		blockTable[renderData.farmDimension][selectedIndex].newState = "land"
		blockTable[renderData.farmDimension][selectedIndex].changingValue = 100
		blockTable[renderData.farmDimension][selectedIndex].changingState = true
		setPedAnimation(player, "bomber", "bom_plant_loop", -1, true, false, false)

		setElementData(player, "isPlayerWorking", true)

		setTimer(function()
			setPedAnimation(player)
			setElementData(player, "isPlayerWorking", false)
			givePlayerHarvestedPlant(localPlayer,seedTable[blockTable[renderData.farmDimension][selectedIndex].plantIndex].itemID, blockTable[renderData.farmDimension][selectedIndex].plantHealth)
			destroyElement(blockTable[renderData.farmDimension][selectedIndex].plantObject)
			blockTable[renderData.farmDimension][selectedIndex].plantIndex = 0
			blockTable[renderData.farmDimension][selectedIndex].plantTimer = growingTime
			blockTable[renderData.farmDimension][selectedIndex].plantSize = 0
			blockTable[renderData.farmDimension][selectedIndex].sizeChanger = 0
			blockTable[renderData.farmDimension][selectedIndex].plantHealth = 100
			blockTable[renderData.farmDimension][selectedIndex].plantHelathChanger = 100
			blockTable[renderData.farmDimension][selectedIndex].healthRemainingTime = healthTime
			blockTable[renderData.farmDimension][selectedIndex].newStateSaveLevel = blockTable[renderData.farmDimension][selectedIndex].newStateLevel
			if player == localPlayer then
				triggerServerEvent("saveBlockTableActionServer", localPlayer, blockTable[renderData.farmDimension], renderData.farmDimension, selectedIndex, type)
			end
		end, harvestTime, 1)
	elseif type == "harvestNoSeed" then
		blockTable[renderData.farmDimension][selectedIndex].newStateSaveLevel = blockTable[renderData.farmDimension][selectedIndex].newStateLevel
		blockTable[renderData.farmDimension][selectedIndex].changingTime = harvestTime
		blockTable[renderData.farmDimension][selectedIndex].changingSlot = selctedIndex
		blockTable[renderData.farmDimension][selectedIndex].changingTick = getTickCount()
		blockTable[renderData.farmDimension][selectedIndex].newState = "land"
		blockTable[renderData.farmDimension][selectedIndex].changingValue = 100
		blockTable[renderData.farmDimension][selectedIndex].changingState = true
		setPedAnimation(player, "bomber", "bom_plant_loop", -1, true, false, false)
		setTimer(function()
			setPedAnimation(player)
			--givePlayerHarvestedPlant(seedTable[blockTable[renderData.farmDimension][selectedIndex].plantIndex].itemID, blockTable[renderData.farmDimension][selectedIndex].plantHealth)
			--destroyElement(blockTable[renderData.farmDimension][selectedIndex].plantObject)
			blockTable[renderData.farmDimension][selectedIndex].plantIndex = 0
			blockTable[renderData.farmDimension][selectedIndex].plantTimer = growingTime
			blockTable[renderData.farmDimension][selectedIndex].plantSize = 0
			blockTable[renderData.farmDimension][selectedIndex].sizeChanger = 0
			blockTable[renderData.farmDimension][selectedIndex].plantHealth = 100
			blockTable[renderData.farmDimension][selectedIndex].plantHelathChanger = 100
			blockTable[renderData.farmDimension][selectedIndex].healthRemainingTime = healthTime
			blockTable[renderData.farmDimension][selectedIndex].newStateSaveLevel = blockTable[renderData.farmDimension][selectedIndex].newStateLevel
			if player == localPlayer then
				triggerServerEvent("saveBlockTableActionServer", localPlayer, blockTable[renderData.farmDimension], renderData.farmDimension, selectedIndex, type)
			end	
		end, harvestTime, 1)
	end
	if player == localPlayer then
		triggerServerEvent("saveBlockTableActionServer", localPlayer, blockTable[renderData.farmDimension], renderData.farmDimension, selectedIndex, type)
	end
end)

addEvent("createFarmItemClient", true)
addEventHandler("createFarmItemClient", getRootElement(), function(player, type, newValue)
	if isElement(createdFarmModels[player]) then
		destroyElement(createdFarmModels[player])
	end

	if isElement(soundEffects[player]) then
		stopSound(soundEffects[player])
	end
	local x,y,z = getElementPosition(player)
	local dimension = getElementDimension(player)
	soundEffects[player] = playSound3D("files/sounds/taketool.mp3", x,y,z, false)
	setElementDimension(soundEffects[player], dimension)

	if newValue then
		if type == "waterCan" then
			createdFarmModels[player] = createObject(16191, 0, 0, 0)
			setElementDimension(createdFarmModels[player], renderData.farmDimension)
			exports.cr_bone_attach:attachElementToBone(createdFarmModels[player], player, 12, -0.05, 0.03, 0.3, 0, -180, 0)
		elseif type == "hoe" then
			createdFarmModels[player] = createObject(16672, 0, 0, 0)
			setElementDimension(createdFarmModels[player], renderData.farmDimension)
			exports.cr_bone_attach:attachElementToBone(createdFarmModels[player], player, 12, 0.2, 0.03, 0.05, 0, 90, -90)
		elseif type == "spade" then
			createdFarmModels[player] = createObject(1901, 0, 0, 0)
			setElementDimension(createdFarmModels[player], renderData.farmDimension)
			exports.cr_bone_attach:attachElementToBone(createdFarmModels[player], player, 12, -0.28, 0.03, 0.05, 0, 0, 90)
		end
	end
end)



function changeBoardTexture(dbID, newName, boardElement)
	dxSetRenderTarget(boardTarget[dbID], true)
		dxDrawImage(0,0,256,128,"files/board.png")
		dxDrawText(utf8.gsub(utf8.upper(newName), "_", " "), 0,0,256,128, tocolor(0, 0, 0, 255), 1, RobotoBold, "center", "center")
	dxSetRenderTarget()
end
addEvent("changeBoardTexture", true)
addEventHandler("changeBoardTexture", getRootElement(), changeBoardTexture)

function createBoardTexture(dbID, newName)
	for k, v in pairs(getElementsByType("object")) do
		local boardID = getElementData(v, "farm:boardID")
		if boardID == dbID then
			local boardOwner = getElementData(v, "farm:boardOwner")
			boardShader[boardID] = dxCreateShader("files/texturechanger.fx")
			boardTarget[boardID] = dxCreateRenderTarget(256, 128)
			engineApplyShaderToWorldTexture(boardShader[boardID], "pole", v)
			dxSetRenderTarget(boardTarget[boardID], true)
				dxDrawImage(0,0,256,128,"files/board.png")
				dxDrawText(newName, 0,0,256,128, tocolor(0, 0, 0, 255), 1, RobotoBold, "center", "center")
			dxSetRenderTarget()
			dxSetShaderValue(boardShader[boardID], "gTexture", boardTarget[boardID])
		end
	end
end
addEvent("createBoardTexture", true)
addEventHandler("createBoardTexture", getRootElement(), createBoardTexture)

function loadFarmModels()
	for k, v in pairs(modelTable) do
		changeObjectModel(v[1],v[2],v[3])
	end
end

function changeObjectModel (filename,filename2,id)
	if id and filename then
		if fileExists(filename..".txd") then
			txd = engineLoadTXD( filename..".txd", true)
			engineImportTXD( txd, id )
		end
		if fileExists(filename2..".dff") then
			dff = engineLoadDFF( filename2..".dff", 0)
			engineReplaceModel( dff, id )
		end
		if fileExists(filename2..".col") then
			col = engineLoadCOL( filename2..".col" )
			engineReplaceCOL( col, id )
		end
	end
end

function loadClientFarmForPlayer()
	setTimer(function()
		for k, v in pairs(getElementsByType("marker")) do
			if getElementData(v, "farm:marker") and getElementData(v, "farm:markerID") > 0 then
				if getElementData(v, "farm:markerID") == getElementDimension(localPlayer) then
					local x,y,z = getElementPosition(localPlayer)
					local markX, markY, markZ = getElementPosition(v)

					if getDistanceBetweenPoints3D(x,y,z,markX,markY,markZ) <= 20 then
						farmMarker = v
					end
				end
			end
		end
	end, 1000, 1)
	for k, v in pairs(getElementsByType("object")) do
		local boardName = getElementData(v, "farm:boardName")
		if boardName then
			local boardID = getElementData(v, "farm:boardID")
			local boardOwner = getElementData(v, "farm:boardOwner")
			boardShader[boardID] = dxCreateShader("files/texturechanger.fx")
			boardTarget[boardID] = dxCreateRenderTarget(256, 128)
			engineApplyShaderToWorldTexture(boardShader[boardID], "pole", v)
			dxSetRenderTarget(boardTarget[boardID], true)
				dxDrawImage(0,0,256,128,"files/board.png")
				if boardOwner == 0 then
					dxDrawText(getTranslatedText("board_forRentText"), 0,0,256,128, tocolor(0, 0, 0, 255), 1, RobotoBold, "center", "center")
				else
					dxDrawText(boardName, 0,0,256,128, tocolor(0, 0, 0, 255), 1, RobotoBold, "center", "center")
				end
			dxSetRenderTarget()
			dxSetShaderValue(boardShader[boardID], "gTexture", boardTarget[boardID])
		end
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(), function()
	loadFarmModels()
	loadClientFarmForPlayer()
end)

bindKey("mouse_wheel_down", "down", function()
	if renderData.plantState then
		if renderData.scrollNum < #seedTable - renderData.maxSeedShow then
			renderData.scrollNum = renderData.scrollNum + 1
		end
	end
end)

bindKey("mouse_wheel_up", "down", function()
	if renderData.plantState then
		if renderData.scrollNum > 0 then
			renderData.scrollNum = renderData.scrollNum - 1
		end
	end
end)

local hitMarker = nil
local notificationData = {}

local imageAboveMarker = dxCreateTexture("files/farmicon.png")
local rentImageAboveMarker = dxCreateTexture("files/farmrenticon.png")

addEventHandler("onClientRender", getRootElement(), function()
	if #notificationData > 0 then
		for k, v in pairs(notificationData) do
			if (v.State == 'openTile') then
			 tileProgress = (getTickCount() - v.Tick) / 250;
			 tilePosition = interpolateBetween(v.StartY, 0, 0, v.EndY, 0, 0, tileProgress, 'Linear');
			elseif (v.State == 'closeTile') then
			 	tileProgress = (getTickCount() - v.Tick) / 250;
			 	tilePosition = interpolateBetween(v.EndY, 0, 0, v.StartY, 0, 0, tileProgress, 'Linear');
			end
			dxDrawRectangle(renderData.interiorX, tilePosition, renderData.interiorW, renderData.interiorH, tocolor(0,0,0,180))
			dxDrawRectangle(renderData.interiorX, tilePosition, 60, renderData.interiorH, tocolor(0,0,0,255))
			if v.owner == 0 then
				dxDrawImage(renderData.interiorX+5, tilePosition+5, 50, 50, "files/farmrenticon.png", 0, 0, 0, tocolor(farmRentMarkerColor[1], farmRentMarkerColor[2], farmRentMarkerColor[3]))
			else
				dxDrawImage(renderData.interiorX+5, tilePosition+5, 50, 50, "files/farmicon.png", 0, 0, 0, tocolor(farmMarkerColor[1], farmMarkerColor[2], farmMarkerColor[3]))
			end
			dxDrawText(v.Name:gsub("\n", " "), renderData.interiorX+70, tilePosition-17, 60, tilePosition+renderData.interiorH, white, 1, Roboto, "left", "center")
			dxDrawText(getTranslatedText("board_enterInterior"), renderData.interiorX+70, tilePosition+20, 60, tilePosition+renderData.interiorH, white, 1, Roboto10, "left", "center")
		end
	end
end)

function farmMarkerHit(thePlayer)
	if thePlayer == localPlayer then
		if getElementDimension(source) == getElementDimension(thePlayer) then
			if getElementData(source, "farm:marker") then
				local px,py,pz = getElementPosition(thePlayer)
				local mx,my,mz = getElementPosition(source)
				if getDistanceBetweenPoints3D(px,py,pz, mx,my,mz) < 2 then
					hitMarker = source
					farmMarker = hitMarker
					bindKey("e", "down", enterFarmInterior)
					bindKey("k", "down", lockFarmInterior)
					if (notificationData ~= nil) then
						table.remove(notificationData, #notificationData);
					end

					table.insert(notificationData,
						{
							StartY = (screenY+(10)),
							EndY = (screenY)-(150),
							Text = "text",
							State = 'openTile',
							Tick = getTickCount(),
							Name = getElementData(hitMarker, "farm:name").." #"..getElementData(hitMarker, "farm:markerID"),
							owner = getElementData(hitMarker, "farm:owner")
						}
					)
					if getElementData(hitMarker, "farm:owner") == 0 then
						outputChatBox(farmPrefix..""..getTranslatedText("chatbox_rentFarmCommand1"), 255,255,255, true)
						outputChatBox(farmPrefix..""..getTranslatedText("chatbox_rentFarmCommand2"), 255,255,255, true)
					end
				end
			end
		end
	end
end
addEventHandler("onClientMarkerHit", getRootElement(), farmMarkerHit)

function leaveFarmMarker(thePlayer)
	if thePlayer == localPlayer then
		if source == hitMarker then
			hitMarker = nil
			unbindKey("e", "down", enterFarmInterior)
			unbindKey("k", "down", lockFarmInterior)
			for k, v in pairs(notificationData) do
				v.State = 'fixTile'
				v.Tick = getTickCount()
				v.State = 'closeTile'
			end
		end
	end
end
addEventHandler("onClientMarkerLeave", getRootElement(), leaveFarmMarker)


function enterFarmInterior()
	if isElement(hitMarker) then
		if not getPedOccupiedVehicle(localPlayer) then
			if getElementData(hitMarker, "farm:owner") > 0 then
				if getElementData(hitMarker, "farm:locked") == 0 then
					farmMarker = hitMarker
					triggerServerEvent("getIntoFarmInterior", localPlayer, localPlayer, hitMarker)
				else
					outputChatBox(farmPrefix..""..getTranslatedText("chatbox_farmLocked"), 255,255,255, true)
				end
			end
		end
	end
end

function lockFarmInterior()
	if isElement(hitMarker) then
		if not getPedOccupiedVehicle(localPlayer) then
			if getElementData(hitMarker, "farm:owner") > 0 then
				if hasPlayerPermission("openState") then
					local lockDoor = 0
					if getElementData(hitMarker, "farm:locked") == 0 then
						lockDoor = 1
					end
					triggerServerEvent("lockFarmInterior", localPlayer, localPlayer, getElementData(hitMarker, "farm:markerID"), lockDoor)
				end
			end
		end
	end
end

function rentFarm(cmd, premium)
	if hitMarker then
		if getElementData(hitMarker, "farm:owner") == 0 then
			if premium == "pp" then
				if getElementData(localPlayer, premiumElementData) >= rentPricePremium then
					triggerServerEvent("rentFarmServer", localPlayer, localPlayer, getElementData(hitMarker, "farm:markerID"), rentPricePremium, premiumElementData)
				else
					outputChatBox(farmPrefix..""..getTranslatedText("chatbox_notEnoughPP"), 255,255,255, true)
				end
			else
				if getElementData(localPlayer, moneyElementData) >= rentPrice then
					triggerServerEvent("rentFarmServer", localPlayer, localPlayer, getElementData(hitMarker, "farm:markerID"), rentPrice, moneyElementData)
				else
					outputChatBox(farmPrefix..""..getTranslatedText("chatbox_notEnoughMoney"), 255,255,255, true)
				end
			end
		else
			outputChatBox(farmPrefix..""..getTranslatedText("chatbox_alreadyOwned"), 255,255,255, true)
		end
	end
end
addCommandHandler("rentfarm", rentFarm)

function isPlayerFacingToElement(playerElement)
	local targetPosX, targetPosY = worldX+(selectedColumn-1)+0.5, worldY+selectedRow+0.5
	local playerPosX, playerPosY = getElementPosition(playerElement)
	if getDistanceBetweenPoints2D(playerPosX, playerPosY, targetPosX, targetPosY) < 1.5 and getDistanceBetweenPoints2D(playerPosX, playerPosY, targetPosX, targetPosY) > 1 then
		local curRotZ = select(3, getElementRotation(playerElement))
		local newRotZ = -math.deg(math.atan2(targetPosX - playerPosX, targetPosY - playerPosY))

		if newRotZ < 0 then
			newRotZ = newRotZ + 360
		elseif newRotZ > 360 then
			newRotZ = newRotZ - 360
		end

		return newRotZ
	else
		outputChatBox(farmPrefix..""..getTranslatedText("chatbox_canNotReach"), 255,255,255, true)
	end
end


function isCursorInterSect3D(hitPosX, hitPosY, worldX, worldY, worldW, worldH)
	if (hitPosX >= worldX and hitPosX <= worldX + worldW and hitPosY >= worldY and hitPosY <= worldY + worldH) then
		return true
	end
	return false
end


function dxDrawButtonWithText(x,y,w,h,buttonColor, hoverColor, text, textColor, scale, font, alignX, alignY, button)
	if isCursorInBox(x,y,w,h) then
		dxDrawRectangle(x,y,w,h, hoverColor)
		if button then
			activeDirectX = button
		end
	else
		dxDrawRectangle(x,y,w,h, buttonColor)
	end
	if alignX == "left" then
		x = x + 5
	end
	dxDrawText(text, x, y, x+w, y+h,textColor, scale, font, alignX, alignY, false,false,false,true)
end

function dxDrawImageButton(x,y,w,h, file, buttonColor, hoverColor)
	if isCursorInBox(x,y,w,h) then
		dxDrawImage(x,y,w,h, file, 0,0,0, hoverColor)
	else
		dxDrawImage(x,y,w,h, file, 0,0,0, buttonColor)
	end
end

function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
  return dxDrawMaterialLine3D( x+2.5, y, z, x+2.5, y+width, z + tonumber( rotation or 0 ), material, -5, color or 0xFFFFFFFF, -8.927734375, -367.939453125,10000)
end

function dxDrawScrollBar(x, y, sz, m, everyObject, seeAble, where, color1, color2)
	if(everyObject > seeAble) then
		dxDrawRectangle(x, y, sz, m, color1 or tocolor(0,0,0,200))
		dxDrawRectangle(x, y+((where)*(m/(everyObject))), sz, m/math.max((everyObject/seeAble),1), color2 or tocolor(102, 153, 204, 255))
	end
end

function isCursorInBox(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(isInBox(xS,yS,wS,hS, cursorX, cursorY)) then
			return true
		else
			return false
		end
	end
end

function isInBox(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end


function dxDrawImageOnElement(TheElement,Image,distance,height,width,R,G,B,alpha)
	if isElement(TheElement) then
		x, y, z = getElementPosition(TheElement)
	else
		x, y, z = unpack(TheElement)
	end
	local x2, y2, z2 = getElementPosition(localPlayer)
	local distance = distance or 20
	local height = height or 1
	local width = width or 1
  local checkBuildings = checkBuildings or true
  local checkVehicles = checkVehicles or false
  local checkPeds = checkPeds or false
  local checkObjects = checkObjects or true
  local checkDummies = checkDummies or true
  local seeThroughStuff = seeThroughStuff or false
  local ignoreSomeObjectsForCamera = ignoreSomeObjectsForCamera or false
  local ignoredElement = ignoredElement or nil
	local sx, sy = getScreenFromWorldPosition(x, y, z+height)
	if(sx) and (sy) then
		local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
		if(distanceBetweenPoints < distance) then
			dxDrawMaterialLine3D(x, y, z+width+height-(distanceBetweenPoints/distance)-0.3, x, y, z+height-0.3, Image, width-(distanceBetweenPoints/distance), tocolor(R or 255, G or 255, B or 255, alpha or 255))
		end
	end
end

function hasPlayerPermission(permissionIndex)
	if getElementData(localPlayer, characterIDElementData) == getElementData(farmMarker, "farm:owner") then
		return true
	end
	for k, v in pairs(permissionTable) do
		if tostring(getElementData(localPlayer, playerNameElementData):gsub("_", " ")) == tostring(v.playerName) then
			if v.permissions[permissionIndex] then
				lastClickTick = getTickCount()
				return true
			else
				return false
			end
		else
			return false
		end
	end
end

function dxDrawTick(x,y,state,toolTipText)
	if state then
		if isCursorInBox(x,y,25,25) then
			dxDrawImage(x,y,25,25,"files/tick.png",0,0,0,tocolor(104,170,249,255))
		else
			dxDrawImage(x,y,25,25,"files/tick.png",0,0,0,tocolor(104,170,249,180))
		end
	else
		if isCursorInBox(x,y,25,25) then
			dxDrawImage(x,y,25,25,"files/minus.png",0,0,0,tocolor(217, 83, 79,255))
		else
			dxDrawImage(x,y,25,25,"files/minus.png",0,0,0,tocolor(217, 83, 79,180))
		end
	end

	if isCursorShowing() then
		local cursorX, cursorY = getCursorPosition()
		local relX, relY = cursorX * screenX, cursorY * screenY
		local textWidth = dxGetTextWidth(toolTipText, 1, Roboto)
		if isCursorInBox(x,y,25,25) then
			dxDrawRectangle(relX+5, relY+5, textWidth+10, 25, tocolor(0,0,0,255), true)
			dxDrawText(toolTipText,relX+10, relY+5, 0,relY+30,white,1,Roboto, "left", "center",false,false,true)
		end
	end
end


function findPlayerByName(thePlayer, partialNick)
	if partialNick == "" then
		return false
	end

	local candidates = {}
	local matchPlayer = nil
	local matchNick = nil
	local matchNickAccuracy = -1
	local partialNick = string.lower(partialNick)

	local players = getElementsByType("player")
	for playerKey, arrayPlayer in ipairs(players) do
		if isElement(arrayPlayer) then
			local playerName = string.lower(getElementData(arrayPlayer, playerNameElementData))
			if(string.find(playerName, tostring(partialNick))) then
				local posStart, posEnd = string.find(playerName, tostring(partialNick))
				if posEnd - posStart > matchNickAccuracy then
					matchNickAccuracy = posEnd-posStart
					matchNick = playerName
					matchPlayer = arrayPlayer
					candidates = { arrayPlayer }
				elseif posEnd - posStart == matchNickAccuracy then
					matchNick = nil
					matchPlayer = nil
					table.insert( candidates, arrayPlayer )
				end
			end
		end
	end

	if not matchPlayer or not isElement(matchPlayer) then
		if isElement( thePlayer ) then
			if #candidates == 0 then
				outputChatBox(farmPrefix..""..getTranslatedText("permission_noPlayerFound"), 255,255,255, true)
			else
				outputChatBox(farmPrefix..""..#candidates.." "..getTranslatedText("permission_morePlayerFound"), 255,255,255, true)
				for _, arrayPlayer in ipairs( candidates ) do
					outputChatBox("  (" .. tostring( getElementData( arrayPlayer, "playerid" ) ) .. ") " .. getElementData(arrayPlayer, playerNameElementData), 255, 255, 255)
				end
			end
		end
		return false
	else
		if matchPlayer == thePlayer then
			outputChatBox(farmPrefix..""..getTranslatedText("permission_selfAdding"), 255,255,255, true)
			return false
		else
			return matchPlayer, getElementData(matchPlayer, playerNameElementData):gsub("_", " ")
		end
	end
end

local width = 350
local max = width/2+40
local plusPos = math.random(0, max)
local minigameY = screenY/2

local tickCount = 0
local showMinigame = false
local minigameStart = false
local minigameState = "lose"
local defaultPrice = 450
local price = defaultPrice
local minigameTimer = nil
local amountOfPlant = 1
local selectedSeedIndex = 0

addEventHandler("onClientClick", getRootElement(), function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if button == "left" and state == "down" then
		if not showMinigame then
			if clickedElement and getElementData(clickedElement, "farm:sellNPC") then
				showMinigame = true
				selectedSeedIndex = getElementData(clickedElement, "farm:sellNPC:seedIndex")
			end
		else
			if isCursorInBox(screenX/2+width/2-52, minigameY - 72, 25, 25) then
				if amountOfPlant < 100 then
					amountOfPlant = amountOfPlant + 1
				end
			elseif isCursorInBox(screenX/2+width/2-25, minigameY - 72, 25, 25) then
				if amountOfPlant > 1 then
					amountOfPlant = amountOfPlant - 1
				end
			elseif isCursorInBox(screenX/2+width/2-10, minigameY - 93, 10, 10) then
				if not minigameStart and showMinigame then
					showMinigame = false
					amountOfPlant = 1
				end
			end
		end
	end
end)

addEventHandler("onClientKey", getRootElement(), function(button, state)
	if showMinigame then
		if button == "space" and state then
			if getItemCount(localPlayer,seedTable[selectedSeedIndex].itemID) >= amountOfPlant then
				tickCount = getTickCount()
				plusPos = math.random(0, max)
				minigameStart = true
				minigameTimer = setTimer(function()
					minigameStart = false
				end, 1300, 1)
			else
				outputChatBox(farmPrefix..""..getTranslatedText("chatbox_noSeed"), 255,255,255, true)
			end
			cancelEvent()
		elseif button == "space" and not state then
			if minigameStart then
				local totalPrice = price*amountOfPlant
				takePlantFromPlayer(localPlayer,seedTable[selectedSeedIndex].itemID, amountOfPlant)
				outputChatBox(farmPrefix..""..getTranslatedText("chatbox_plantSold"), 255,255,255, true)
				outputChatBox(farmPrefix..""..getTranslatedText("chatbox_minigame_amount").." #99cc99"..amountOfPlant.." "..getTranslatedText("piecesShortly"), 255,255,255, true)
				outputChatBox(farmPrefix..""..getTranslatedText("chatbox_minigame_price").." #99cc99$"..price.." / "..getTranslatedText("piecesShortly"), 255,255,255, true)
				outputChatBox(farmPrefix..""..getTranslatedText("chatbox_minigame_total").." #99cc99$"..totalPrice, 255,255,255, true)
				triggerServerEvent("giveMoneyForPlant", localPlayer, localPlayer, totalPrice)
				amountOfPlant = 1
				price = 0
				minigameStart = false
				showMinigame = false
				if isTimer(minigameTimer) then
					killTimer(minigameTimer)
				end
			end
		end
	end
end)

addEventHandler("onClientRender", getRootElement(), function()
	if showMinigame then
		dxDrawRectangle(screenX/2-width/2-10, minigameY - 100, width+20, 25, tocolor(0, 0, 0, 255))
		dxDrawText(getTranslatedText("minigameTitle").." "..seedTable[selectedSeedIndex].name, screenX/2-width/2-5, minigameY - 102, screenX/2-width/2-10, minigameY - 75, white, 1, Roboto, "left", "center",false,false,false,true)

		dxDrawRectangle(screenX/2-width/2-10, minigameY - 75, width+20, 30, tocolor(153, 204, 153, 200))
		dxDrawText(getTranslatedText("chatbox_minigame_amount").." "..amountOfPlant, screenX/2-width/2-5, minigameY - 75, screenX/2-width/2-10, minigameY - 45, tocolor(0,0,0,255), 1, Roboto10, "left", "center",false,false,false,true)
		dxDrawImageButton(screenX/2+width/2-52, minigameY - 72, 25, 25, "files/plus.png", tocolor(0,0,0,255), tocolor(255, 255, 255, 255))
		dxDrawImageButton(screenX/2+width/2-25, minigameY - 72, 25, 25, "files/minus.png", tocolor(0,0,0,255), tocolor(255, 255, 255, 255))
		dxDrawImageButton(screenX/2+width/2-10, minigameY - 93, 10, 10, "files/close.png", tocolor(255,255,255,255), tocolor(217, 83, 79, 255))

		dxDrawRectangle(screenX/2-width/2-10, minigameY - 45, width+20, 130, tocolor(0,0,0,200))
		dxDrawText(getTranslatedText("chatbox_minigame_price").." #99cc99$"..price.." / "..getTranslatedText("piecesShortly"), screenX/2-width/2, minigameY - 45, screenX/2+width/2, minigameY - 20, white, 1, Roboto10, "center", "center",false,false,false,true)
		dxDrawRectangle(screenX/2-width/2, minigameY, width, 15, tocolor(0, 0, 0))

		if minigameStart then
			local currentTick = getTickCount()
			local progress = (currentTick - tickCount) / 1200
			local sinX = interpolateBetween(screenX/2-width/2-8, 0, 0, screenX/2+width/2-8, 0, 0, progress, "Linear")
			local posX = width/2 - plusPos

			if sinX >= screenX/2-posX + (width/2-40-width/13)/2-8 and sinX <= screenX/2-posX + (width/2-40-width/13)/2 + width/13-8 then
				color = tocolor(153, 204, 153)
				minigameState = "win"
				price = defaultPrice
			elseif sinX <= screenX/2-posX+width/2-40-8 and sinX >= screenX/2-posX-8 then
				color = tocolor(255, 153, 51)
				minigameState = "mid"
				price = defaultPrice - 12
			else
				color = tocolor(217, 83, 79)
				minigameState = "lose"
				price = defaultPrice - 23
			end

			dxDrawImage(sinX, minigameY - 20, 16, 16, "files/triangle.png", 0,0,0,color)
			dxDrawRectangle(screenX/2-width/2, minigameY, width, 15, tocolor(217, 83, 79))
			dxDrawRectangle(screenX/2-posX, minigameY, width/2-40, 15, tocolor(255, 153, 51))
			dxDrawRectangle(screenX/2-posX + (width/2-40-width/13)/2, minigameY, width/13, 15, tocolor(153, 204, 153))
		end
		dxDrawText(getTranslatedText("chatbox_minigame_description"), screenX/2-width/2, minigameY+15, screenX/2+width/2, minigameY+85, white, 0.9, Roboto11, "center", "center",false,false,false,true)
	end
end)


addCommandHandler("startscene", function()
	for k, v in pairs(blockTable[renderData.farmDimension]) do
		if v.blockColumn ~= 3 then

			v.waterChanger = 100
			v.waterLevel = 100
			v.wateringTick = getTickCount()
			v.wateringState = true
			v.waterLossTime = waterLosingTime
			v.waterLossTick = getTickCount()
			v.state = "land_planted"
			if v.blockColumn == 1 then
				v.plantIndex = 3
			end
			if v.blockColumn == 2 then
				v.plantIndex = 2
			end
			if v.blockColumn == 4 then
				v.plantIndex = 4
			end
			if v.blockColumn == 5 then
				v.plantIndex = 6
			end
			v.plantTimer = growingTime
			v.plantObject = createObject(seedTable[v.plantIndex].modelID, worldX+(v.blockColumn-1)+0.5, worldY+v.blockRow+0.5, 4.45+seedTable[v.plantIndex].zCorrection)
			setObjectScale(v.plantObject, 0)
			setElementDimension(v.plantObject, renderData.farmDimension)

			v.plantTick = getTickCount()
			v.healthTick = getTickCount()
		end
		triggerServerEvent("saveBlockTableActionServer", localPlayer, blockTable[renderData.farmDimension], renderData.farmDimension, 1, "")
	end
end)
