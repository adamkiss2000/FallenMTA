connection = exports['cr_mysql']:getConnection(getThisResource())
addEventHandler("onResourceStart", root, 
    function(startedRes)
        if getResourceName(startedRes) == "cr_mysql" then
            connection = exports['cr_mysql']:getConnection(getThisResource())
            restartResource(getThisResource())
        end
    end
)


local createdFarmModels = {}
local farmEffects = {}
local farmInMarker = {}
local farmOutMarker = {}
local farmInteriors = {}
local farmInteriors2 = {}
local farmHoes = {}
local farmSpades = {}
local farmWaterCans = {}

local blockTables = {}
local permissionTables = {}

local farmExteriors = {}
local farmBoards = {}
local farmTimers = {}

local sellNPCTable = {}

setFPSLimit(60)


addEvent("syncNewSurfaceToServer", true)
addEventHandler("syncNewSurfaceToServer", root, function(selectedIndex, type, player, seedIndex, dimid)
    for k, v in pairs(getElementsByType("player")) do
     if getElementData(v, "farm:inFarmID") and getElementData(v, "farm:inFarmID") == dimid then
        triggerClientEvent(v, "syncNewSurfaceToClient", source, selectedIndex, type, player, seedIndex)
      end
    end
end)

addEvent("saveBlockTableActionServer", true)
addEventHandler("saveBlockTableActionServer", root, function(table, dimid, index, type)
  if not blockTables[dimid] then
    blockTables[dimid] = table
  else
    for k, v in pairs(blockTables[dimid]) do
      v.state = table[k].state
      v.newState = table[k].newState
      v.newStateLevel = table[k].newStateLevel
      v.newStateSaveLevel = table[k].newStateSaveLevel
      v.changingTick = table[k].changingTick
      v.changingState = table[k].changingState
      v.changingSlot = table[k].changingSlot
      v.changingValue = table[k].changingValue
      v.changingTime = table[k].changingTime
      -- # Planted Seed
      v.plantObject = table[k].plantObject
      v.plantTimer = table[k].plantTimer
      v.plantSize = table[k].plantSize
      v.plantFullSize = table[k].plantFullSize
      --v.plantTick = table[k].
      v.plantIndex = table[k].plantIndex
      v.plantHealth = table[k].plantHealth
      v.plantHelathChanger = table[k].plantHelathChanger
      v.healthRemainingTime = table[k].healthRemainingTime
      --v.healthTick = table[k].healthTick
      v.sizeChanger = table[k].sizeChanger
      -- # Water variables
      v.waterLevel = table[k].waterLevel
      v.waterChanger = table[k].waterChanger
      v.wateringState = table[k].wateringState
      v.wateringTick = table[k].wateringTick
    end
  end
  if type == "planting" then
    blockTables[dimid][index].plantTick = getTimestamp()
  elseif type == "watering" then
    blockTables[dimid][index].waterLossTick = getTimestamp()
  end
end)

addEvent("createFarmItemServer", true)
addEventHandler("createFarmItemServer", root, function(player, type, clickedTool, newValue)
  triggerClientEvent(getElementsByType("player"), "createFarmItemClient", source, player, type, newValue)

  if newValue then
    if type == "hoe" then
      setElementData(clickedTool, "farm:hoeObjectNumber", getElementData(clickedTool, "farm:hoeObjectNumber")-1)
    elseif type == "spade" then
      setElementData(clickedTool, "farm:spadeObjectNumber", getElementData(clickedTool, "farm:spadeObjectNumber")-1)
    elseif type == "waterCan" then
      setElementData(clickedTool, "farm:waterCanObjectNumber", getElementData(clickedTool, "farm:waterCanObjectNumber")-1)
    end
  else
    if type == "hoe" then
      setElementData(clickedTool, "farm:hoeObjectNumber", getElementData(clickedTool, "farm:hoeObjectNumber")+1)
    elseif type == "spade" then
      setElementData(clickedTool, "farm:spadeObjectNumber", getElementData(clickedTool, "farm:spadeObjectNumber")+1)
    elseif type == "waterCan" then
      setElementData(clickedTool, "farm:waterCanObjectNumber", getElementData(clickedTool, "farm:waterCanObjectNumber")+1)
    end
  end
end)

addEvent("getIntoFarmInterior", true)
addEventHandler("getIntoFarmInterior", root, function(player, marker)
  local intDim = getElementData(marker, "farm:dimension")
  setElementPosition(player, unpack(getElementData(marker, "farm:position")))
  setElementDimension(player, intDim)
  if intDim > 0 then
    -- TODO IDE
    loadFarmForPlayer(player, intDim)
    setElementData(player, "farm:inFarmID", intDim)
  else
    triggerClientEvent(player, "syncBlockTableClient", player, player, false, true)
    setElementData(player, "farm:inFarmID", 0)
  end
end)

addEvent("lockFarmInterior", true)
addEventHandler("lockFarmInterior", root, function(player, markerID, lockState)
  setElementData(farmInMarker[markerID], "farm:locked", lockState)
  setElementData(farmOutMarker[markerID], "farm:locked", lockState)
  if lockState == 0 then
    outputChatBox(farmPrefix..""..getTranslatedText("chatbox_openFarmDoor"), player, 255,255,255, true)
  else
    outputChatBox(farmPrefix..""..getTranslatedText("chatbox_closeFarmDoor"), player, 255,255,255, true)
  end
end)

addEvent("changeFarmInteriorName", true)
addEventHandler("changeFarmInteriorName", root, function(dimID, newName)
  dbExec(connection, "UPDATE farms SET name = ? WHERE id = ?", newName, dimID)
  for k, v in pairs(getElementsByType("marker")) do
    if getElementData(v, "farm:markerID") and getElementData(v, "farm:markerID") == dimID then
      setElementData(v, "farm:name", newName)
    end
  end
  triggerClientEvent(getElementsByType("player"), "changeBoardTexture", source, dimID, newName)
end)

addEvent("rentFarmServer", true)
addEventHandler("rentFarmServer", root, function(player, markerID, price, elementData)
  if getElementData(player, elementData) >= price then
    local playerName = getElementData(player, playerNameElementData):gsub("_", " ")
    dbExec(connection, "UPDATE farms SET owner = ?, name = ?, rentTime = ? WHERE id = ?", getElementData(player, characterIDElementData), getElementData(player, playerNameElementData), defaultRentTime, markerID)
    setMarkerColor(farmInMarker[markerID], farmMarkerColor[1], farmMarkerColor[2], farmMarkerColor[3], farmMarkerColor[4])
    setElementData(farmInMarker[markerID], "farm:owner", getElementData(player, characterIDElementData))
    setElementData(farmOutMarker[markerID], "farm:owner", getElementData(player, characterIDElementData))
    setElementData(farmOutMarker[markerID], "farm:name", playerName)
    setElementData(farmInMarker[markerID], "farm:name", playerName)
    triggerClientEvent(getElementsByType("player"), "changeBoardTexture", player, markerID, playerName)
    -- # Remove money / Premium point
    setElementData(player, elementData, getElementData(player, elementData)-price)
    -- # Start the rent timer
    farmTimers[markerID] = setTimer(function()
      dbExec(connection, "UPDATE farms SET owner = ?, blockTable = NULL, permissionTable = '[[]]' WHERE id = ? ", 0, markerID)
      blockTables[markerID] = nil
      permissionTables[markerID] = {}
      setElementData(farmOutMarker[markerID], "farm:owner", 0)
      setElementData(farmInMarker[markerID], "farm:owner", 0)
      setMarkerColor(farmInMarker[markerID], farmRentMarkerColor[1], farmRentMarkerColor[2], farmRentMarkerColor[3], farmRentMarkerColor[4])
      print("[Server]: Rent is over. "..markerID)
    end, defaultRentTime, 1)
    -- # Feedback text
    outputChatBox(farmPrefix..""..getTranslatedText("chatbox_rentSuccess"), player, 255,255,255,true)
  else
    outputChatBox(farmPrefix..""..getTranslatedText("chatbox_notEnoughPP"), player, 255,255,255,true)
  end
end)

addEvent("giveMoneyForPlant", true)
addEventHandler("giveMoneyForPlant", root, function(player, amount)
  setElementData(player, moneyElementData, getElementData(player, moneyElementData)+amount)
end)

addEvent("savePermissionTable", true)
addEventHandler("savePermissionTable", root, function(player, dbid, table)
  permissionTables[dbid] = table
end)


addCommandHandler("createfarm", function(thePlayer, cmd, numberOfSize)
  if exports['cr_admin']:getAdminLevel(thePlayer) >= 9 then
  if not numberOfSize or tonumber(numberOfSize) < 1 then
    outputChatBox("[Farm]: /farm [Size of Farm]",thePlayer)
  else
    numberOfSize = tonumber(numberOfSize)
    local lastInsertID = 0
    for i = 1, numberOfSize do
      local x, y, z = getElementPosition(thePlayer)
      if i > 1 then
        x, y = getPositionFromElementOffset(farmExteriors[lastInsertID],5.2,-7.5,0)
      end
      local _, _, rot = getElementRotation(thePlayer)
      local farmInsertQuery = dbQuery(connection, "INSERT INTO farms SET x = ?, y = ?, z = ?, rotation = ?", x,y,z, rot)
      local success, _, insertID = dbPoll(farmInsertQuery, -1)
      if success then
        loadFarmFromDatabase(insertID)
      end
      triggerClientEvent(getElementsByType("player"), "createBoardTexture", thePlayer, insertID, getTranslatedText("board_forRentText"))
      lastInsertID = insertID
    end
  end
end
end)





addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), function()
  local allFarmQuery = dbPoll(dbQuery(connection,"SELECT * FROM farms"),-1)
  if allFarmQuery then
    for k, v in pairs(allFarmQuery) do
      loadFarmFromDatabase(v["id"])
    end
    setTimer(function()
      for k, v in pairs(getElementsByType("player")) do
        local farmID = getElementData(v, "farm:inFarmID")
        if farmID and farmID > 0 then
          loadFarmForPlayer(v, farmID)
        end
      end
    end, 500, 1)
  end
  -- # Create the sell npcs
  for k, v in pairs(seedSellTable) do
    sellNPCTable[k] = createPed(v.skinID, v.position[1], v.position[2], v.position[3], v.position[4])
    local stand = createObject(1239, v.position[1], v.position[2], v.position[3] - 0.5)

    if isElement(stand) and isElement(sellNPCTable[k]) then
      attachElements(stand, sellNPCTable[k], 0, 0.6, 0, 0, 0, 180)
      setElementFrozen(sellNPCTable[k], true)
      setElementData(sellNPCTable[k], "farm:sellNPC", true)
      setElementData(sellNPCTable[k], "farm:sellNPC:seedIndex", v.seedIndex)
      setElementData(sellNPCTable[k], "nameEnabled", true)
      setElementData(sellNPCTable[k], "ped.name", "Felvásárló - "..seedTable[v.seedIndex].name)
      setElementData(sellNPCTable[k], "ped.type", "NPC")
    end
  end
end)

addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), function()
  for k, v in pairs(farmInMarker) do
    if blockTables[k] then
      dbExec(connection, "UPDATE farms SET blockTable = ? WHERE id = ?", toJSON(blockTables[k]), k)
    end

    if isTimer(farmTimers[k]) then
      local rentTimeLeft = getTimerDetails(farmTimers[k])
      dbExec(connection, "UPDATE farms SET rentTime = ?, permissionTable = ? WHERE id = ?", rentTimeLeft, toJSON(permissionTables[k]), k)
    end
  end
end)


function loadFarmFromDatabase(dbID)
  local farmQuery = dbPoll(dbQuery(connection,"SELECT * FROM farms WHERE id = ?", dbID),-1)
  if farmQuery then
    for k, v in pairs(farmQuery) do
      -- # Create In Marker
      local markerColor = {farmMarkerColor[1], farmMarkerColor[2], farmMarkerColor[3], farmMarkerColor[4]}
      if v["owner"] == 0 then
        markerColor = {farmRentMarkerColor[1], farmRentMarkerColor[2], farmRentMarkerColor[3], farmRentMarkerColor[4]}
      else
        -- # Start the rent timer
        farmTimers[dbID] = setTimer(function()
          dbExec(connection, "UPDATE farms SET owner = ?, blockTable = NULL, permissionTable = '[[]]' WHERE id = ? ", 0, dbID)
          blockTables[dbID] = nil
          permissionTables[dbID] = {}
          setElementData(farmOutMarker[dbID], "farm:owner", 0)
          setElementData(farmInMarker[dbID], "farm:owner", 0)
          setMarkerColor(farmInMarker[dbID], farmRentMarkerColor[1], farmRentMarkerColor[2], farmRentMarkerColor[3], farmRentMarkerColor[4])
          print("[Server]: Rent Time ended")
        end, v["rentTime"], 1)
      end
      farmInMarker[dbID] = createMarker(v["x"], v["y"], v["z"]-1, "cylinder", 0.7, markerColor[1], markerColor[2], markerColor[3], markerColor[4])
      setElementData(farmInMarker[dbID], "farm:marker", true)
      setElementData(farmInMarker[dbID], "farm:markerID", dbID)
      setElementData(farmInMarker[dbID], "farm:position", {farmInteriorPosition[1], farmInteriorPosition[2], farmInteriorPosition[3]})
      setElementData(farmInMarker[dbID], "farm:dimension", dbID)
      setElementData(farmInMarker[dbID], "farm:name", v["name"])
      setElementData(farmInMarker[dbID], "farm:owner", v["owner"])
      setElementData(farmInMarker[dbID], "farm:locked", v["locked"])
      -- # Create Out Marker
      farmOutMarker[dbID] = createMarker(farmInteriorPosition[1], farmInteriorPosition[2], farmInteriorPosition[3]-1, "cylinder", 0.7, farmMarkerColor[1], farmMarkerColor[2], farmMarkerColor[3], farmMarkerColor[4])
      setElementData(farmOutMarker[dbID], "farm:marker", true)
      setElementData(farmOutMarker[dbID], "farm:markerID", dbID)
      setElementData(farmOutMarker[dbID], "farm:position", {v["x"], v["y"], v["z"]})
      setElementData(farmOutMarker[dbID], "farm:dimension", 0)
      setElementData(farmOutMarker[dbID], "farm:name", v["name"])
      setElementData(farmOutMarker[dbID], "farm:owner", v["owner"])
      setElementData(farmOutMarker[dbID], "farm:locked", v["locked"])
      setElementDimension(farmOutMarker[dbID], dbID)
      -- # Create the Farm Modells
      
      farmInteriors2[dbID] = createObject(16671, worldX+3.1-0.60, worldY+3.45, 4.4)
      farmInteriors[dbID] = createObject(16673, worldX+3.1-0.60, worldY+3.45, 4.4)
      setElementDimension(farmInteriors[dbID], dbID)
      setElementDimension(farmInteriors2[dbID], dbID)
      setElementAlpha(farmInteriors[dbID], 0)
      -- # Create the hoes
      farmHoes[dbID] = createObject(16672, worldX+0.03, worldY-1.87, 5.2, -90, 180)
      setElementDimension(farmHoes[dbID], dbID)
      setElementData(farmHoes[dbID], "farm:hoeObject", true)
      setElementData(farmHoes[dbID], "farm:hoeObjectNumber", numberOfHoesAllowedInFarm)
      -- # Create the spades
      farmSpades[dbID] = createObject(1901, worldX+0.03, worldY-2.22, 5.8, -90, 90)
      setElementDimension(farmSpades[dbID], dbID)
      setElementData(farmSpades[dbID], "farm:spadeObject", true)
      setElementData(farmSpades[dbID], "farm:spadeObjectNumber", numberOfSpadesAllowedInFarm)
      -- # Create water cans
      farmWaterCans[dbID] = createObject(16191, worldX+4.5, worldY-1.3, 5.46, 0, 0, 110)
      setElementDimension(farmWaterCans[dbID], dbID)
      setElementData(farmWaterCans[dbID], "farm:waterCanObject", true)
      setElementData(farmWaterCans[dbID], "farm:waterCanObjectNumber", numberOfSpadesAllowedInFarm)
      -- # Create Exterior Object
      local x,y,z = getPositionInfrontOfElement(v["x"], v["y"], v["z"]-1, v["rotation"], 7.5)
      farmExteriors[dbID] = createObject(16673,x,y,z)
      setElementRotation(farmExteriors[dbID], 0, 0, v["rotation"])
      -- # Create farm board
      farmBoards[dbID] = createObject(16674,0,0,0)
      attachElements(farmBoards[dbID], farmExteriors[dbID], 0.025, -6.65, 1.3, 0)
      setElementCollisionsEnabled(farmBoards[dbID], false)
      setElementData(farmBoards[dbID], "farm:boardName", v["name"])
      setElementData(farmBoards[dbID], "farm:boardID", dbID)
      setElementData(farmBoards[dbID], "farm:boardOwner", v["owner"])
      -- # Set the block table
      if v["blockTable"] then
        blockTables[dbID] = fromJSON(v["blockTable"])
      end
      -- # Set the permission table
      if v["permissionTable"] then
        permissionTables[dbID] = fromJSON(v["permissionTable"])
      else
        permissionTables[dbID] = {}
      end
    end
  end
end

function loadFarmForPlayer(player, farmID, permissions)
  --if getElementData(v, "farm:inFarmID") and getElementData(v, "farm:inFarmID") > 0 then
    local atvTable = nil
    if blockTables[farmID] then
      atvTable = blockTables[farmID]
      for k, v in pairs(atvTable) do
        if v.plantIndex and v.plantIndex > 0 then
          v.sizeChanger = v.plantFullSize * ((getTimestamp()-v.plantTick)*1000 / growingTime)
          if v.sizeChanger > v.plantFullSize then
            v.sizeChanger = v.plantFullSize
          end
          v.plantSize = v.sizeChanger
          v.plantTimer = growingTime - (getTimestamp() - v.plantTick)*1000
          if v.plantTimer < 1 then
            v.plantTimer = 1
          end
        end
        -- # Water Level Calculations
        if v.waterLevel > 0 or v.waterChanger > 0 then
          v.waterLevel = 100 - (100 * ((getTimestamp()-v.waterLossTick)*1000 / waterLosingTime))
          v.waterLossTime = waterLosingTime - (getTimestamp() - v.waterLossTick)*1000
          --print("block_"..k..": "..v.waterLevel)
          v.waterChanger = v.waterLevel
          if v.waterLossTime < 1 then
            -- # Plant Health Calculations
            if v.plantHealth > 0 or v.plantHelathChanger > 0 then
              local calculatedWaterLoss = -v.waterLossTime
              v.plantHealth = 100 - 100 * calculatedWaterLoss / healthTime
              v.healthRemainingTime = healthTime - calculatedWaterLoss

              v.plantHelathChanger = v.plantHealth

              if v.plantHealth < 0 then
                v.plantHealth = 0
                v.plantHelathChanger = 0
                v.healthRemainingTime = 0
              end
            end
            v.waterLossTime = 1
          end
        end
        if v.waterLevel < 0 then
          v.waterLevel = 0
          v.waterChanger = 0
        end
        if v.waterChanger < 0 then
          v.waterChanger = 0
        end
      end
    end
    triggerClientEvent(player, "syncBlockTableClient", player, player, atvTable, false, permissionTables[farmID])
  --end
end

-- # Basic Assets

function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second

    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second

    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end

    return timestamp
end

function getPositionInfrontOfElement(x,y,z, rot, meters)
    local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = x,y,z
    posX = posX - math.sin(math.rad(rot)) * meters
    posY = posY + math.cos(math.rad(rot)) * meters
    rot = rot + math.cos(math.rad(rot))
    return posX, posY, posZ , rot
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z -- Return the transformed point
end
