function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

screenX, screenY = guiGetScreenSize()
responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

function getResponsiveMultipler()
	return responsiveMultipler
end

local vectors = {}

function dxDrawRoundedRectangle(x, y, sx, sy, color, postGUI, subPixelPositioning)
	dxDrawImage(x, y, 5, 5, roundtexture, 0, 0, 0, color, postGUI)
	dxDrawRectangle(x, y + 5, 5, sy - 5 * 2, color, postGUI, subPixelPositioning)
	dxDrawImage(x, y + sy - 5, 5, 5, roundtexture, 270, 0, 0, color, postGUI)
	dxDrawRectangle(x + 5, y, sx - 5 * 2, sy, color, postGUI, subPixelPositioning)
	dxDrawImage(x + sx - 5, y, 5, 5, roundtexture, 90, 0, 0, color, postGUI)
	dxDrawRectangle(x + sx - 5, y + 5, 5, sy - 5 * 2, color, postGUI, subPixelPositioning)
	dxDrawImage(x + sx - 5, y + sy - 5, 5, 5, roundtexture, 180, 0, 0, color, postGUI)
end

function createVector(width, height, rawData)
	local svgElm = svgCreate(width, height, rawData)
	local svgXML = svgGetDocumentXML(svgElm)
	local rect = xmlFindChild(svgXML, 'rect', 0)

	return {
		svg = svgElm,
		xml = svgXML,
		rect = rect
	}
end

function createCircleStroke(id, width, height, sizeStroke)
	if (not id) then return end
	if (not (width or height)) then return end
	if (not vectors[id]) then
		sizeStroke = sizeStroke or 2
		local radius = math.min(width, height) / 2
		local radiusLength = (2 * math.pi) * radius
		local newWidth, newHeight = width + (sizeStroke * 2), height + (sizeStroke * 2)
		local raw = string.format([[
			<svg width='%s' height='%s' >
				<rect x='%s' y='%s' rx='%s' width='%s' height='%s' fill='#FFFFFF' fill-opacity='0' stroke='#FFFFFF'
				stroke-width='%s' stroke-dasharray='%s' stroke-dashoffset='%s' stroke-linecap='round' stroke-linejoin='round' />
			</svg>
		]], newWidth, newHeight, sizeStroke, sizeStroke, radius, width, height, sizeStroke, radiusLength, 0)
		local svg = createVector(width, height, raw)
		local attributes = {
			type = 'circle-stroke',
			svgDetails = svg,
			width = width,
			height = height,
			radiusLength = radiusLength
		}
		vectors[id] = attributes
	end
	return vectors[is]
end

function createCircle(id, width, height)
	if (not id) then return end
	if (not (width or height)) then return end
	if (not vectors[id]) then
		width = width or 1
		height = height or 1
		local radius = math.min(width, height) / 2
		local raw = string.format([[
			<svg width='%s' height='%s' >
				<rect rx='%s' width='%s' height='%s' fill='#FFFFFF' />
			</svg>
		]], width, height, radius, width, height)
		local svg = createVector(width, height, raw)
		local attributes = {
			type = 'circle',
			svgDetails = svg,
			width = width,
			height = height,
		}
		vectors[id] = attributes
	end
	return vectors[id]
end

cacheHealth = {false, 0, getTickCount()}
cacheArmor = {false, 0, getTickCount()}
cacheHunger = {false, 0, getTickCount()}
cacheThirst = {false, 0, getTickCount()}
cacheStamina = {false, 0, getTickCount()}


function setSVGOffset(id, value)
	if id == "health" then
		if (not vectors[id]) then return end
		local svg = vectors[id]
		if (cacheHealth[2] ~= nil) then
			if (not cacheHealth[1]) then
				cacheHealth[3] = getTickCount()
				cacheHealth[1] = true
			end
			local progress = (getTickCount() - cacheHealth[3]) / 2500
			cacheHealth[2] = interpolateBetween(cacheHealth[2], 0, 0, value, 0, 0, progress, 'OutQuad')
			if (progress > 1) then
				cacheHealth[3] = nil
				cacheHealth[1] = false
			end
			local rect = svg.svgDetails.rect
			local newValue = svg.radiusLength - (svg.radiusLength / 100) * cacheHealth[2]
			xmlNodeSetAttribute(rect, 'stroke-dashoffset', newValue)
			svgSetDocumentXML(svg.svgDetails.svg, svg.svgDetails.xml)
		elseif (cacheHealth[1]) then
			cacheHealth[1] = false
		end
	elseif id == "armor" then
		if (not vectors[id]) then return end
		local svg = vectors[id]
		if (cacheArmor[2] ~= nil) then
			if (not cacheArmor[1]) then
				cacheArmor[3] = getTickCount()
				cacheArmor[1] = true
			end
			local progress = (getTickCount() - cacheArmor[3]) / 2500
			cacheArmor[2] = interpolateBetween(cacheArmor[2], 0, 0, value, 0, 0, progress, 'OutQuad')
			if (progress > 1) then
				cacheArmor[3] = nil
				cacheArmor[1] = false
			end
			local rect = svg.svgDetails.rect
			local newValue = svg.radiusLength - (svg.radiusLength / 100) * cacheArmor[2]
			xmlNodeSetAttribute(rect, 'stroke-dashoffset', newValue)
			svgSetDocumentXML(svg.svgDetails.svg, svg.svgDetails.xml)
		elseif (cacheArmor[1]) then
			cacheArmor[1] = false
		end
	elseif id == "hunger" then
		if (not vectors[id]) then return end
		local svg = vectors[id]
		if (cacheHunger[2] ~= nil) then
			if (not cacheHunger[1]) then
				cacheHunger[3] = getTickCount()
				cacheHunger[1] = true
			end
			local progress = (getTickCount() - cacheHunger[3]) / 2500
			cacheHunger[2] = interpolateBetween(cacheHunger[2], 0, 0, value, 0, 0, progress, 'OutQuad')
			if (progress > 1) then
				cacheHunger[3] = nil
				cacheHunger[1] = false
			end
			local rect = svg.svgDetails.rect
			local newValue = svg.radiusLength - (svg.radiusLength / 100) * cacheHunger[2]
			xmlNodeSetAttribute(rect, 'stroke-dashoffset', newValue)
			svgSetDocumentXML(svg.svgDetails.svg, svg.svgDetails.xml)
		elseif (cacheHunger[1]) then
			cacheHunger[1] = false
		end
	elseif id == "thirst" then
		if (not vectors[id]) then return end
		local svg = vectors[id]
		if (cacheThirst[2] ~= nil) then
			if (not cacheThirst[1]) then
				cacheThirst[3] = getTickCount()
				cacheThirst[1] = true
			end
			local progress = (getTickCount() - cacheThirst[3]) / 2500
			cacheThirst[2] = interpolateBetween(cacheThirst[2], 0, 0, value, 0, 0, progress, 'OutQuad')
			if (progress > 1) then
				cacheThirst[3] = nil
				cacheThirst[1] = false
			end
			local rect = svg.svgDetails.rect
			local newValue = svg.radiusLength - (svg.radiusLength / 100) * cacheThirst[2]
			xmlNodeSetAttribute(rect, 'stroke-dashoffset', newValue)
			svgSetDocumentXML(svg.svgDetails.svg, svg.svgDetails.xml)
		elseif (cacheThirst[1]) then
			cacheThirst[1] = false
		end
    elseif id == "stamina" then
		if (not vectors[id]) then return end
		local svg = vectors[id]
		if (cacheStamina[2] ~= nil) then
			if (not cacheStamina[1]) then
				cacheStamina[3] = getTickCount()
				cacheStamina[1] = true
			end
			local progress = (getTickCount() - cacheStamina[3]) / 2500
			cacheStamina[2] = interpolateBetween(cacheStamina[2], 0, 0, value, 0, 0, progress, 'OutQuad')
			if (progress > 1) then
				cacheStamina[3] = nil
				cacheStamina[1] = false
			end
			local rect = svg.svgDetails.rect
			local newValue = svg.radiusLength - (svg.radiusLength / 100) * cacheStamina[2]
			xmlNodeSetAttribute(rect, 'stroke-dashoffset', newValue)
			svgSetDocumentXML(svg.svgDetails.svg, svg.svgDetails.xml)
		elseif (cacheStamina[1]) then
			cacheStamina[1] = false
		end
	end
end

function drawItem(id, x, y, color, postGUI)
	if (not vectors[id]) then return end
	if (not (x or y)) then return end
	local svg = vectors[id]
	postGUI = postGUI or false
	color = color or 0xFFFFFFFF
	local width, height = svg.width, svg.height
	dxSetBlendMode('add')
	dxDrawImage(x, y, width, height, svg.svgDetails.svg, 0, 0, 0, color, postGUI)
	dxSetBlendMode('blend')
end

local screenW, screenH = guiGetScreenSize()
local circleScale, sizeStroke = 51, respc(2.9) --65, 3.9
local iconScale = 25
local circleLeft, circleTop = circleScale + respc(30), screenH/2 - circleScale - respc(20)

addEventHandler("onClientResourceStart", resourceRoot, function()
	createCircle("bgHealth", circleScale, circleScale)
	createCircle("bgArmor", circleScale, circleScale)
	createCircle("bgHunger", circleScale, circleScale)
	createCircle("bgThirst", circleScale, circleScale)
	createCircle("bgStamina", circleScale, circleScale)
	createCircleStroke("health", circleScale, circleScale, sizeStroke)
	createCircleStroke("armor", circleScale, circleScale, sizeStroke)
	createCircleStroke("hunger", circleScale, circleScale, sizeStroke)
	createCircleStroke("thirst", circleScale, circleScale, sizeStroke)
	createCircleStroke("stamina", circleScale, circleScale, sizeStroke)
end)

function lineddRectangle(x,y,w,h,color,color2,size)
    if not color then
        color = tocolor(51, 51, 51, 255 * 0.8);
    end
    if not color2 then
        color2 = color;
    end
    if not size then
        size = 1.7;
    end
	_dxDrawRectangle(x, y, w, h, color);
	_dxDrawRectangle(x - size, y - size, w + (size*2), size, color2);
	_dxDrawRectangle(x - size, y + h, w + (size*2), size, color2);
	_dxDrawRectangle(x - size, y, size, h, color2);
	_dxDrawRectangle(x + w, y, size, h, color2);
end

function drawnIcon(x, y, icon)
    dxDrawImage(x - 30/2, y - 30/2, 30, 30, "hud/files/"..icon..".png");
end

local function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY)
    dxDrawText(text,x,y+1,w,h+1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x,y-1,w,h-1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x-1,y,w-1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x+1,y,w+1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
end

local function shadowedText2(text,x,y,w,h,color,fontsize,font,aligX,alignY)
    local digits = 6
    local text2 = string.gsub(text, "#" .. (digits and string.rep("%x", digits) or "%x+"), "")
    dxDrawText(text2,x,y+1,w,h+1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text2,x,y-1,w,h-1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text2,x-1,y,w-1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text2,x+1,y,w+1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
    dxDrawText(text,x,y,w,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, false, false, false, true);
end

function stringBoolean(string)
    if string == "true" then
        return true;
    else
        return false;
    end
end

local logged = getElementData(localPlayer, "loggedIn");
local hudVisible = getElementData(localPlayer, "hudVisible");

local ping = getPlayerPing(localPlayer);
local hexColor = "#7cc576";
function getPingColor(ping)
    local color = "#F2F2F2";
    
    if ping <= 60 then
        color = exports['cr_core']:getServerColor("green", true);
    elseif ping <= 130 then
        color = exports['cr_core']:getServerColor("lightyellow", true);
    elseif ping >= 130 then
        color = exports['cr_core']:getServerColor("red", true);
    end
    
    return color;
end

function convertNumber(number)  
	local formatted = number;
	while true do      
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2'); 
		if (k == 0) then      
			break;
		end  
	end  
	return formatted;
end
---------------------------------------------------

local id = getElementData(localPlayer, "char >> id") or -1;
local sx, sy = guiGetScreenSize();

local pingColor = getPingColor(ping)
local money = getElementData(localPlayer, "char >> money");
local moneyChanging = false;
local newMoney = 0;
local maxmoneynuls = 10;
local moneynulsText = "000000000000000000000000000000000000000000000000";
local moneynuls = utfSub(moneynulsText, 1, math.max(0, maxmoneynuls - string.len(tostring(money))));
local typeColors = {
    ["+"] = "#7cc576",
    ["-"] = "#d23131",
};

local nameFont = dxCreateFont("hud/files/font2.ttf", 20);

local level = getElementData(localPlayer, "char >> level") or 1;
local name = tostring(getElementData(localPlayer, "char >> name") or "Invalid"):gsub("_", " ");

function getFPSColor(num)
    local num = tonumber(num) or 0;
    local color = "#F2F2F2";
    
    if num >= 45 then
        color = exports['cr_core']:getServerColor("green", true);
    elseif num >= 25 then
        color = exports['cr_core']:getServerColor("lightyellow", true);
    elseif num <= 25 then
        color = exports['cr_core']:getServerColor("red", true);
    end
    
    return color .. num .. " #ffffffFPS";
end

local counter = 0;
local rfps = "80 FPS";
local starttick = false;
 
fps = getFPSColor(80);

local time = getRealTime();
local time1 = time.hour;
if time1 < 10 then
    time1 = "0" .. tostring(time1);
end
local time2 = time.minute;
if time2 < 10 then
    time2 = "0" .. tostring(time2);
end

local time = getRealTime();
local month = time.month + 1;
local str = tostring(month);
if month < 10 then
    str = "0" .. str;
end
local monthday = time.monthday;
local str2 = tostring(monthday);
if monthday < 10 then
    str2 = "0" .. str2;
end
local year = tostring(tonumber(time.year) + 1900)
local datum =  year.."."..str.."."..str2;
local datum2 =  year.."."..str.."."..str2;

local premiumPoints = convertNumber(tonumber(getElementData(localPlayer, "char >> premiumPoints") or 0));
local maxpremiumnuls = 10;
local premiumnuls = utfSub(moneynulsText, 1, math.max(0, maxpremiumnuls - string.len(tostring(premiumPoints))));

local details = dxGetStatus();
local cardDatas = {
    ["vname"] = details["VideoCardName"],
    ["vram"] = details["VideoCardRAM"],
    ["vfram"] = details["VideoMemoryFreeForMTA"],
    ["vfont"] = details["VideoMemoryUsedByFonts"],
    ["vtexture"] = details["VideoMemoryUsedByTextures"],
    ["vtarget"] = details["VideoMemoryUsedByRenderTargets"],
    ["vratio"] = details["SettingAspectRatio"],
    ["vcolor"] = details["Setting32BitColor"],
};

local packetloss = getNetworkStats()["packetlossTotal"];
local packetloss = math.floor(packetloss);
if cardDatas["vcolor"] then
    cardDatas["vcolor"] = 32;
else 
    cardDatas["vcolor"] = 16;
end

local bone = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true};

-- draws ->

function dxDrawOuterBorder(x, y, w, h, borderSize, borderColor, postGUI)
	borderSize = borderSize or 2
	borderColor = borderColor or tocolor(0, 0, 0, 255)
	
    local dxDrawRectangle = _dxDrawRectangle
	dxDrawRectangle(x - borderSize, y - borderSize, w + (borderSize * 2), borderSize, borderColor, postGUI)
	dxDrawRectangle(x, y + h, w, borderSize, borderColor, postGUI)
	dxDrawRectangle(x - borderSize, y, borderSize, h + borderSize, borderColor, postGUI)
	dxDrawRectangle(x + w, y, borderSize, h + borderSize, borderColor, postGUI)
end

local widgets = {};

local playerDetails = {
    ["health"] = 0,
    ["realhealth"] = 0,
    
    ["food"] = 0,
    ["realfood"] = 0,
    
    ["drink"] = 0,
    ["realdrink"] = 0,
    
    ["armor"] = 0,
    ["realarmor"] = 0,
    
    ["stamina"] = 0,
    ["realstamina"] = 0,
    
    ["playedtime"] = 0,
    ["realplayedtime"] = 0,
    ["lastLevelTime"] = 0,
    ["nextLevelTime"] = 0,
    
    ["avatar"] = 0,
    ["level"] = 0,
}

function updatePlayerDetails()
    if not localPlayer:getData("loggedIn") then return end
    
    playerDetails["avatar"] = tonumber(localPlayer:getData("char >> avatar")) or 1
    
    if playerDetails["health"] ~= localPlayer.health then
        playerDetails["health"] = localPlayer.health
        playerDetails["healthAnimation"] = true
        playerDetails["healthAnimationTick"] = getTickCount()
    end

    if playerDetails["armor"] ~= localPlayer.armor then
        playerDetails["armor"] = localPlayer.armor
        playerDetails["armorAnimation"] = true
        playerDetails["armorAnimationTick"] = getTickCount()
    end
    
    local k = "food"
    if tonumber(localPlayer:getData("char >> "..k)) then
        if playerDetails[k] ~= localPlayer:getData("char >> "..k) then
            playerDetails[k] = localPlayer:getData("char >> "..k)
            playerDetails[k.."Animation"] = true
            playerDetails[k.."AnimationTick"] = getTickCount()
        end
    end
    
    local k = "drink"
    if tonumber(localPlayer:getData("char >> "..k)) then
        if playerDetails[k] ~= localPlayer:getData("char >> "..k) then
            playerDetails[k] = localPlayer:getData("char >> "..k)
            playerDetails[k.."Animation"] = true
            playerDetails[k.."AnimationTick"] = getTickCount()
        end
    end
    
    --[[
    if playerDetails["stamina"] ~= stamina then
        playerDetails["stamina"] = stamina
        playerDetails["staminaAnimation"] = true
        playerDetails["staminaAnimationTick"] = getTickCount()
    end
    
    local level = tonumber(localPlayer:getData("char >> level") or 1)
    if level then
        playerDetails["level"] = level
        playerDetails["lastLevelTime"] = exports['cr_level']:getLevelTime(level) or 0
        playerDetails["nextLevelTime"] = exports['cr_level']:getLevelTime(level + 1) or 0
    end
    
    local k = "playedtime"
    if tonumber(localPlayer:getData("char >> "..k)) then
        if playerDetails[k] ~= localPlayer:getData("char >> "..k) then
            playerDetails[k] = localPlayer:getData("char >> "..k)
            playerDetails[k.."Animation"] = true
            playerDetails[k.."AnimationTick"] = getTickCount()
        end
    end
    
    --playerDetails["playedtime"] = tonumber(localPlayer:getData("char >> playedtime")) or 0]]
end
setTimer(updatePlayerDetails, 250, 0)

startAnimation = "InOutQuad"
startAnimationTime = 250 -- 0.2 mp
function drawWidgets()
    if not hudVisible then return end
    
    local nowTick = getTickCount();

    if widgets["hp"] then 
        local alpha = 255

        local enabled,x,y,w,h,sizable,turnable = getDetails("hp");

        local k = "health"
        if playerDetails[k.."Animation"] then
            local startTick = playerDetails[k.."AnimationTick"]
            local endTick = startTick + 250
            
            local elapsedTime = nowTick - startTick
            local duration = (startTick + startAnimationTime) - startTick
            local progress = elapsedTime / duration
            local alph = interpolateBetween(
                playerDetails["real"..k], 0, 0,
                playerDetails[k], 0, 0,
                progress, startAnimation
            )
            playerDetails["real"..k] = alph
            
            if progress >= 1 then
                playerDetails[k.."Animation"] = false
            end
            --multipler = alph / 100
        end
        local multipler = playerDetails["real"..k] / 100
        
        --local h = 35 * multipler
        local alpha = 255

        if #bloodData >= 1 then 
            local now = getTickCount()
            alpha = interpolateBetween(0, 0, 0, 255, 0, 0, now / 2500, "SineCurve")
        end
        setSVGOffset('health', getElementHealth(localPlayer))
        drawItem('bgHealth', x, y, tocolor(28, 28, 28, 170))
        drawItem('allBgStat', x, y, tocolor(15, 15, 15))
        drawItem('health', x, y, tocolor(255, 50, 50))
        dxDrawImage(x + ((circleScale/2) - (iconScale/2)), y + ((circleScale/2) - (iconScale/2)), iconScale, iconScale, "hud/files/health-icon.png", 0, 0, 0, tocolor(255, 50, 50))
        if not editorState and exports['cr_core']:isInSlot(x, y, 51, 51) then 
            exports['cr_dx']:drawTooltip(1, math.floor(multipler * 100) .. "%")
        end 
    end 

    if widgets["armor"] then 
        local alpha = 255

        local enabled,x,y,w,h,sizable,turnable = getDetails("armor");

        local k = "armor"
        if playerDetails[k.."Animation"] then
            local startTick = playerDetails[k.."AnimationTick"]
            local endTick = startTick + 250
            
            local elapsedTime = nowTick - startTick
            local duration = (startTick + startAnimationTime) - startTick
            local progress = elapsedTime / duration
            local alph = interpolateBetween(
                playerDetails["real"..k], 0, 0,
                playerDetails[k], 0, 0,
                progress, startAnimation
            )
            playerDetails["real"..k] = alph
            
            if progress >= 1 then
                playerDetails[k.."Animation"] = false
            end
            --multipler = alph / 100
        end
        local multipler = playerDetails["real"..k] / 100
        
        --local h = 35 * multipler
        local alpha = 255
        setSVGOffset('armor', playerDetails["real"..k])
        drawItem('bgArmor', x, y, tocolor(28, 28, 28, 170))
	    drawItem('allBgStat', x, y, tocolor(15, 15, 15))
	    drawItem('armor', x,  y, tocolor(66, 134, 244))
	    dxDrawImage(x + ((circleScale/2) - (iconScale/2)), y + ((circleScale/2) - (iconScale/2)), iconScale, iconScale, "hud/files/armor-icon.png", 0, 0, 0, tocolor(66, 134, 244))
        if not editorState and exports['cr_core']:isInSlot(x, y, 51, 51) then 
            exports['cr_dx']:drawTooltip(1, math.floor(multipler * 100) .. "%")
        end 
    end 

    if widgets["hunger"] then 
        local alpha = 255

        local enabled,x,y,w,h,sizable,turnable = getDetails("hunger");

        local k = "food"
        if playerDetails[k.."Animation"] then
            local startTick = playerDetails[k.."AnimationTick"]
            local endTick = startTick + 250
            
            local elapsedTime = nowTick - startTick
            local duration = (startTick + startAnimationTime) - startTick
            local progress = elapsedTime / duration
            local alph = interpolateBetween(
                playerDetails["real"..k], 0, 0,
                playerDetails[k], 0, 0,
                progress, startAnimation
            )
            playerDetails["real"..k] = alph
            
            if progress >= 1 then
                playerDetails[k.."Animation"] = false
            end
            --multipler = alph / 100
        end
        local multipler = playerDetails["real"..k] / 100
        
        --local h = 35 * multipler
        local alpha = 255
        setSVGOffset('hunger', playerDetails["real"..k] or 0)
        drawItem('bgHunger', x, y, tocolor(28, 28, 28, 170))
	    drawItem('allBgStat', x, y, tocolor(15, 15, 15))
	    drawItem('hunger', x, y, tocolor(223, 181, 81))
        dxDrawImage(x + ((circleScale/2) - (iconScale/2)), y + ((circleScale/2) - (iconScale/2)), iconScale, iconScale, "hud/files/food-icon.png", 0, 0, 0, tocolor(223, 181, 81))
        if not editorState and exports['cr_core']:isInSlot(x, y, 51, 51) then 
            exports['cr_dx']:drawTooltip(1, math.floor(multipler * 100) .. "%")
        end 
    end 

    if widgets["thirsty"] then 
        local alpha = 255

        local enabled,x,y,w,h,sizable,turnable = getDetails("thirsty");

        local k = "drink"
        if playerDetails[k.."Animation"] then
            local startTick = playerDetails[k.."AnimationTick"]
            local endTick = startTick + 250
            
            local elapsedTime = nowTick - startTick
            local duration = (startTick + startAnimationTime) - startTick
            local progress = elapsedTime / duration
            local alph = interpolateBetween(
                playerDetails["real"..k], 0, 0,
                playerDetails[k], 0, 0,
                progress, startAnimation
            )
            playerDetails["real"..k] = alph
            
            if progress >= 1 then
                playerDetails[k.."Animation"] = false
            end
            --multipler = alph / 100
        end
        local multipler = playerDetails["real"..k] / 100
        
        --local h = 35 * multipler
        local alpha = 255
        setSVGOffset('thirst', playerDetails["real"..k] or 0)
        drawItem('bgThirst', x , y, tocolor(28, 28, 28, 170))
	    drawItem('allBgStat', x , y, tocolor(15, 15, 15))
	    drawItem('thirst', x , y, tocolor(97, 226, 252))
	    dxDrawImage(x  + ((circleScale/2) - (iconScale/2)), y + ((circleScale/2) - (iconScale/2)), iconScale, iconScale, "hud/files/drink-icon.png", 0, 0, 0, tocolor(97, 226, 252))

        if not editorState and exports['cr_core']:isInSlot(x, y, 51, 51) then 
            exports['cr_dx']:drawTooltip(1, math.floor(multipler * 100) .. "%")
        end 
    end 

    if widgets["stamina"] then 
        local alpha = 255

        local enabled,x,y,w,h,sizable,turnable = getDetails("stamina");

        local multipler = stamina / 100
        
        --local h = 35 * multipler
        local alpha = 255
        setSVGOffset('stamina', stamina)
        drawItem('bgStamina', x, y, tocolor(28, 28, 28, 170))
	    drawItem('allBgStat', x, y, tocolor(15, 15, 15))
	    drawItem('stamina', x, y, tocolor(255, 255, 255))
	    dxDrawImage(x + ((circleScale/2) - (iconScale/2)), y + ((circleScale/2) - (iconScale/2)), iconScale, iconScale, "hud/files/stamina-icon.png", 0, 0, 0, tocolor(255, 255, 255))
        if not editorState and exports['cr_core']:isInSlot(x, y, 40, 40) then 
            exports['cr_dx']:drawTooltip(1, math.floor(multipler * 100) .. "%")
        end 
    end 
    
   
    if widgets["ping"] then
        local pingFont = exports['cr_fonts']:getFont("BebasNeueBold", 14)

        local enabled,x,y,w,h,sizable,turnable = getDetails("ping");
        
        shadowedText(ping .. " MS", x, y, x + w, y + h + 4, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true); 
        dxDrawText(pingColor .. ping .. " #ffffffMS", x, y, x + w, y + h + 4, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
    end
    
    if widgets["money"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("money");
        if math.floor(w / 12) ~= maxmoneynuls then
            maxmoneynuls = w / 12;
            moneynuls = utfSub(moneynulsText, 1, math.max(0, maxmoneynuls - string.len(tostring(money))));
        end
        local font = exports['cr_fonts']:getFont("BebasNeueBold", 19)
        if moneyChanging then
            shadowedText(moneyChangeType .. newMoney .. " $", x, y, x + w, y + h, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, true);
            dxDrawText(moneyChangeType .. typeColors[moneyChangeType] .. newMoney .. " $", x, y, x + w, y + h, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, true);
        else
            if money < 0 then
                shadowedText(moneynuls .. money .." $", x, y, x + w, y + h, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, true);
                dxDrawText(moneynuls .. typeColors["-"] .. money .." $", x, y, x + w, y + h, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, true);
            else
                shadowedText(moneynuls .. money .." $", x, y, x + w, y + h, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, true);
                dxDrawText(moneynuls .. hexColor .. money .." $", x, y, x + w, y + h, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, true);
            end
        end
    end
    
    if widgets["name"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("name");
        local hexColor = exports['cr_core']:getServerColor("yellow", true)
        shadowedText(name .. " ("..id..") - Szint: " .. level, x, y, x + w, y + h, tocolor(255,255,255,255), 1, nameFont, "center", "center", false, false, false, true);
        dxDrawText(name .. " #ffffff("..hexColor..id.."#ffffff) - Szint: " .. hexColor .. level, x, y, x + w, y + h, tocolor(255,255,255,255), 1, nameFont, "center", "center", false, false, false, true);
    end
    
    if widgets["fps"] then
        local pingFont = exports['cr_fonts']:getFont("BebasNeueBold", 14)

        local enabled,x,y,w,h,sizable,turnable = getDetails("fps");
        shadowedText(rfps, x, y, x + w, y + h + 4, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
        dxDrawText(fps, x, y, x + w, y + h + 4, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
    end
    
    if widgets["time"] then
        local pingFont = exports['cr_fonts']:getFont("BebasNeueBold", 15)

        local enabled,x,y,w,h,sizable,turnable = getDetails("time");
        dxDrawImage(x, y, w, h, "hud/files/time-bg.png", 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawText(time1..":" .. time2, x + 23, y, x + w, y + h - 2, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
    end
    
    if widgets["datum"] then
        local pingFont = exports['cr_fonts']:getFont("BebasNeueBold", 15)

        local enabled,x,y,w,h,sizable,turnable = getDetails("datum");
        shadowedText(datum, x, y, x + w, y + h + 4, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
        dxDrawText(datum2, x, y, x + w, y + h + 4, tocolor(242,242,242,255), 1, pingFont, "center", "center", false, false, false, true);
    end
    
    if widgets["videocard"] then
        local pingFont = exports['cr_fonts']:getFont("BebasNeueBold", 15)

        local enabled,x,y,w,h,sizable,turnable = getDetails("videocard");
        local hexColor = exports['cr_core']:getServerColor("yellow", true)
        local text = hexColor .. cardDatas["vname"] .. "#ffffff\nVRAM: "..hexColor..cardDatas["vram"] - cardDatas["vfram"].."/" .. cardDatas["vram"] .. "#ffffff MB, FONT: " .. hexColor .. cardDatas["vfont"] .. "#ffffff MB \nTEXTURE: " .. hexColor .. cardDatas["vtexture"] .. " #ffffffMB, RTARGET: " .. hexColor .. cardDatas["vtarget"] .. "#ffffff MB\nRATIO: " .. hexColor .. cardDatas["vratio"] .. "#ffffff, SIZE: "..hexColor..sx.."#ffffffx"..hexColor..sy.."#ffffffx"..hexColor..cardDatas["vcolor"]
        local text2 =  cardDatas["vname"] .. "\nVRAM: "..cardDatas["vram"] - cardDatas["vfram"].."/" .. cardDatas["vram"] .. " MB, FONT: " .. cardDatas["vfont"] .. " MB \nTEXTURE: " .. cardDatas["vtexture"] .. " MB, RTARGET: " .. cardDatas["vtarget"] .. " MB\nRATIO: " .. cardDatas["vratio"] .. ", SIZE: "..sx.."x"..sy.."x"..cardDatas["vcolor"]
        local digits = 6
        shadowedText(text2, x, y, x + w, y + h + 4, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, false);
        dxDrawText(text, x, y, x + w, y + h + 4, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
    end
                    
    if widgets["packetloss"] then
        local pingFont = exports['cr_fonts']:getFont("BebasNeueBold", 15)

        local hexColor = exports['cr_core']:getServerColor("green", true)
        local enabled,x,y,w,h,sizable,turnable = getDetails("packetloss")
        shadowedText("Adatveszteség: "..packetloss.." %", x, y, x + w, y + h + 4, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
        dxDrawText("Adatveszteség: "..hexColor..packetloss.." #ffffff%", x, y, x + w, y + h + 4, tocolor(255,255,255,255), 1, pingFont, "center", "center", false, false, false, true);
    end
    
    if widgets["premiumPoints"] then
        local font = exports['cr_fonts']:getFont("BebasNeueBold", 19)
        local hexColor = exports['cr_core']:getServerColor("yellow", true)
        local enabled,x,y,w,h,sizable,turnable = getDetails("premiumPoints");
        
        if math.floor(w / 12) ~= maxpremiumnuls then
            maxpremiumnuls = w / 12;
            --local moneynulsText = "000000000000000000000000000000000000000000000000";
            premiumnulsnuls = utfSub(moneynulsText, 1, math.max(0, maxpremiumnuls - string.len(tostring(premiumPoints))));
        end
        shadowedText(premiumnulsnuls .. premiumPoints .. " PP", x, y, x + w, y + h, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, true);
        dxDrawText(premiumnulsnuls .. hexColor .. premiumPoints .. " PP", x, y, x + w, y + h, tocolor(255,255,255,255), 1, font, "left", "center", false, false, false, true);
    end
    
    if widgets["bone"] then
        local enabled,x,y,w,h,sizable,turnable = getDetails("bone")
        local w,h = 50, 50
        local x, y = x - 10, y
        --dxDrawImage(x - 2, y - 2, w + 4, h + 4, "hud/files/bone.png", 0,0,0, tocolor(0,0,0,255));
        dxDrawImage(x, y, w, h, "hud/files/bone.png", 0,0,0, tocolor(255,255,255,255));
        if not bone[2] then
            dxDrawImage(x, y, w, h, "hud/files/injureLeftArm.png", 0,0,0, tocolor(255,255,255,255));
        end
        if not bone[3] then
            dxDrawImage(x, y, w, h, "hud/files/injureRightArm.png", 0,0,0, tocolor(255,255,255,255));
        end
        if not bone[4] then
            dxDrawImage(x, y, w, h, "hud/files/injureLeftFoot.png", 0,0,0, tocolor(255,255,255,255));
        end
        if not bone[5] then
            dxDrawImage(x, y, w, h, "hud/files/injureRightFoot.png", 0,0,0, tocolor(255,255,255,255));
        end
    end
end
---------------------------------------------------------------

-- timers ->
setTimer(
    function()
        if not logged then return end
        if getElementData(localPlayer, "inDeath") then return end
        --if getElementData(localPlayer, "char >> tazed") then return end
        if getElementData(localPlayer, "char >> ajail") then return end
        --if getElementData(localPlayer, "char >> cuffed") then return end
        if not exports.cr_admin:getAdminDuty(localPlayer) then
            local oldFood = (tonumber(getElementData(localPlayer, "char >> food")) or 100);
            local foodNull = false;
            --local drinkNull = false;

            if oldFood - 0.05 >= 0 then
                setElementData(localPlayer, "char >> food", oldFood - 0.05);

                if oldFood - 0.05 <= 20 then
                    if not isTimer(foodWarningTimer) then
                        foodWarningTimer = setTimer(function()
                            exports['cr_infobox']:addBox("warning", "Kezdesz éhes lenni, egyél valamit!");
                        end, 15 * 60000, 0);
                    end
                else
                    if isTimer(foodWarningTimer) then killTimer(foodWarningTimer) end
                end
            else
                if isTimer(foodWarningTimer) then killTimer(foodWarningTimer) end

                setElementData(localPlayer, "char >> food", 0);
                foodNull = true;
            end

            local oldDrink = (tonumber(getElementData(localPlayer, "char >> drink")) or 100);
            local drinkNull = false;

            if oldDrink - 0.1 >= 0 then
                setElementData(localPlayer, "char >> drink", oldDrink - 0.1);
                if oldDrink - 0.1 <= 20 then
                    if not isTimer(drinkWarningTimer) then
                        drinkWarningTimer = setTimer(function()
                            exports['cr_infobox']:addBox("warning", "Kezdesz szomjas lenni, igyál valamit!");
                        end, 15 * 60000, 0);
                    end
                else
                    if isTimer(drinkWarningTimer) then killTimer(drinkWarningTimer) end
                end
            else
                if isTimer(drinkWarningTimer) then killTimer(drinkWarningTimer) end
                setElementData(localPlayer, "char >> drink", 0);
                drinkNull = true;
            end

            if drinkNull and not foodNull then
                local health = getElementHealth(localPlayer);
                if health - 20 <= 0 then
                    localPlayer:setData("specialReason", "Szomjan halt")
                    localPlayer.health = 0
                else 
                    setElementHealth(localPlayer, health - 20);
                end
            elseif drinkNull and foodNull then
                localPlayer:setData("specialReason", "Éhen és szomjan halt")
                localPlayer.health = 0
            elseif not drinkNull and foodNull then
                local health = getElementHealth(localPlayer);
                if health - 50 <= 0 then
                    localPlayer:setData("specialReason", "Éhen halt")
                    localPlayer.health = 0
                else 
                    setElementHealth(localPlayer, health - 50);
                end
            end
        end
    end, 
40 * 1000, 0);

setTimer(function()
    if widgets and widgets["ping"] then
        ping = getPlayerPing(localPlayer);
        pingColor = getPingColor(ping);
    end
end, 2000, 0);

setTimer(function()
    if widgets and widgets["time"] then
        time = getRealTime()
        time1 = time.hour
        if time1 < 10 then
            time1 = "0" .. tostring(time1)
        end
        time2 = time.minute
        if time2 < 10 then
            time2 = "0" .. tostring(time2)
        end
    end
end, 2000, 0);

setTimer(function()
    if widgets and widgets["datum"] then
        local time = getRealTime();
        local month = time.month + 1;
        local str = tostring(month);
        if month < 10 then
            str = "0" .. str;
        end
        local monthday = time.monthday;
        local str2 = tostring(monthday);
        if monthday < 10 then
            str2 = "0" .. str2;
        end
        local year = tostring(tonumber(time.year) + 1900)
        datum = year.."."..str.."."..str2;
        datum2 =  year.."."..str.."."..str2;
    end
end, 60 * (60 * 1000), 0);

setTimer(function()
    if widgets and widgets["videocard"] then
        details = dxGetStatus();
        cardDatas = {
            ["vname"] = details["VideoCardName"],
            ["vram"] = details["VideoCardRAM"],
            ["vfram"] = details["VideoMemoryFreeForMTA"],
            ["vfont"] = details["VideoMemoryUsedByFonts"],
            ["vtexture"] = details["VideoMemoryUsedByTextures"],
            ["vtarget"] = details["VideoMemoryUsedByRenderTargets"],
            ["vratio"] = details["SettingAspectRatio"],
            ["vcolor"] = details["Setting32BitColor"],
        };
        packetloss = getNetworkStats()["packetlossTotal"];
        packetloss = math.floor(packetloss);
        if cardDatas["vcolor"] then
            cardDatas["vcolor"] = 32;
        else 
            cardDatas["vcolor"] = 16;
        end
    end
end, 1000, 0);

addEventHandler("onClientRender",root, function()
    if not starttick then
        starttick = getTickCount();
    end
    counter = counter + 1;
    currenttick = getTickCount ();
    if currenttick - starttick >= 1000 then
        rfps = counter .. " FPS";
        fps = getFPSColor(counter);
        counter = 0;
        starttick = false;
    end
end, true, "low");

function getFPS()
    return rfps
end 
---------------------------------------------------------------

local datas = {
    ["name.enabled"] = "name",
    ["fps.enabled"] = "fps",
    ["time.enabled"] = "time",
    ["datum.enabled"] = "datum",
    ["premiumPoints.enabled"] = "premiumPoints",
    ["videocard.enabled"] = "videocard",
    ["packetloss.enabled"] = "packetloss",
    ["bone.enabled"] = "bone",
    ["ping.enabled"] = "ping",
    ["money.enabled"] = "money",
    --["level.enabled"] = "level",
    ["hp.enabled"] = "hp",
    ["armor.enabled"] = "armor",
    ["hunger.enabled"] = "hunger",
    ["thirsty.enabled"] = "thirsty",
    ["stamina.enabled"] = "stamina",
    ["healthbar.enabled"] = "healthbar",
    ["armorbar.enabled"] = "armorbar",
    ["foodbar.enabled"] = "foodbar",
    ["drinkbar.enabled"] = "drinkbar",
    ["staminabar.enabled"] = "staminabar",
};

function checkDatas(dataName)
    if dataName and datas[dataName] then
        local state = getElementData(localPlayer, dataName);
        if state then
            widgets[datas[dataName]] = true;
        else
            widgets[datas[dataName]] = false;
        end
    else
        for i, k in pairs(datas) do
            local state = getElementData(localPlayer, i);
            if state then
                widgets[k] = true;
            else
                widgets[k] = false;
            end
        end
    end
end

bloodData = {}
addEventHandler("onClientElementDataChange", localPlayer, function(dName, oValue, nValue)
    if dName == "bloodData" then 
        bloodData = nValue 
        return 
    end 

    if dName == "char >> id" then
    	id = tonumber(getElementData(localPlayer, dName)) or 1
    end
        
    if dName == "char >> level" then
        level = tonumber(getElementData(localPlayer, dName)) or 1;
        return;
    end
        
    if dName == "char >> name" then
        name = tostring(getElementData(localPlayer, dName) or "Invalid"):gsub("_", " ");
        return;
    end
    if dName == "loggedIn" then
        checkDatas();
        logged = getElementData(localPlayer, dName);
        --addEventHandler("onClientRender", getRootElement(), drawWidgets, true, "low");
        createRender("drawWidgets", drawWidgets)
        return;
    end
    if dName == "char >> bone" then
        bone = getElementData(localPlayer, "char >> bone") or {true, true, true, true, true};
        return
    end
        
    if dName == "hudVisible" then
        hudVisible = getElementData(localPlayer, dName);
        return;
    end
        
    if datas[dName] then
        checkDatas(dName);
    end
        
    if dName == "char >> premiumPoints" then
        premiumPoints = convertNumber(getElementData(source, dName));
        --nuls = utfSub(nulsText, 1, math.max(0, maxNuls - string.len(tostring(premiumPoints))));
        premiumnuls = utfSub(moneynulsText, 1, maxpremiumnuls - string.len(tostring(premiumPoints)));
        return;
    end
        
    if oValue == nil or not oValue then oValue = 0 end
    if dName == "char >> money" then
        local value = getElementData(source, dName);
        moneynuls = utfSub(moneynulsText, 1, maxmoneynuls - string.len(tostring(value)));
        money = convertNumber(value);
        if value > oValue then
            moneyChangeType = "+";
            newMoney = value - oValue;
            money = typeColors[moneyChangeType] .. money;
        elseif oValue > value then
            moneyChangeType = "-";
            newMoney = oValue - value;
            money = typeColors[moneyChangeType] .. money;
        end
        if logged then
            playSound("files/moneychange.mp3");
        end
        money = convertNumber(money);
        moneyChanging = true;
        setTimer(function()
            moneyChanging = false;
            money = getElementData(localPlayer, "char >> money");
            moneynuls = utfSub(moneynulsText, 1, math.max(0, maxmoneynuls - string.len(tostring(money))));
        end, 2500, 1);
        return;
    end
end, true, "low");

addEventHandler("onClientResourceStart", resourceRoot,function()
    if getElementData(localPlayer, "loggedIn") then
        checkDatas();
        --addEventHandler("onClientRender", getRootElement(), drawWidgets, true, "low");
        createRender("drawWidgets", drawWidgets)
    end
end);

--local sX, sY = guiGetScreenSize()
function isInSlot(dX, dY, dSZ, dM)
    return exports['cr_core']:isInSlot(dX, dY, dSZ, dM)
end

