--------------------------------------------------
-- PROXIMITY SYSTEM
--------------------------------------------------

local colMinimum
local colMedium
local colMaximum

local function createColSystems()
    colMinimum = createColSphere(0,0,0,8)
    colMedium = createColSphere(0,0,0,16)
    colMaximum = createColSphere(0,0,0,32)

    attachElements(colMinimum, localPlayer)
    attachElements(colMedium, localPlayer)
    attachElements(colMaximum, localPlayer)
end

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        createColSystems()
    end
)

function getNearbyPlayers(range)
    range = range or "medium"

    local col =
        (range == "minimum" and colMinimum) or
        (range == "medium" and colMedium) or
        (range == "maximum" and colMaximum)

    if not col then return {} end

    local players = getElementsWithinColShape(col, "player")
    local result = {}

    for _, p in ipairs(players) do
        if p ~= localPlayer then
            table.insert(result, p)
        end
    end

    return result
end

function getPlayerCol(range)
    return
        (range == "minimum" and colMinimum) or
        (range == "medium" and colMedium) or
        (range == "maximum" and colMaximum)
end

--------------------------------------------------
-- GHOST MODE
--------------------------------------------------

local ghostedElements = {}

addEvent("cr_gameplay:ghostMode", true)
addEventHandler("cr_gameplay:ghostMode", root,
    function(element, state, alpha, settings)
        if not isElement(element) then return end

        if state == "on" then
            for _, v in ipairs(getElementsByType(element.type)) do
                setElementCollidableWith(element, v, false)
            end

            element:setData("ghostMode", true)

            if alpha then
                element.alpha = alpha
            end

            ghostedElements[element] = true

        elseif state == "off" then
            for _, v in ipairs(getElementsByType(element.type)) do
                setElementCollidableWith(element, v, true)
            end

            element:setData("ghostMode", false)
            element.alpha = 255

            ghostedElements[element] = nil
        end
    end
)

--------------------------------------------------
-- HUD TOGGLE (F9)
--------------------------------------------------

local hudVisible = true

bindKey("F9", "down",
    function()
        hudVisible = not hudVisible
        showChat(hudVisible)
        setElementData(localPlayer, "hudVisible", hudVisible)
    end
)

--------------------------------------------------
-- DAMAGE BLOCK
--------------------------------------------------

addEventHandler("onClientPedDamage", root,
    function()
        if getElementData(source, "char >> noDamage") then
            cancelEvent()
        end
    end
)

addEventHandler("onClientPlayerStealthKill", localPlayer,
    function(target)
        if getElementData(target, "char >> noDamage") then
            cancelEvent()
        end
    end
)

--------------------------------------------------
-- NUMBER ONLY GUI
--------------------------------------------------

addEventHandler("onClientGUIChanged", root,
    function()
        if not getElementData(source, "onlyNumber") then return end
        guiSetText(source, guiGetText(source):gsub("[^0-9]", ""))
    end
)

--------------------------------------------------
-- MODEL STREAM FIX
--------------------------------------------------

addEventHandler("onClientElementModelChange", root,
    function(oldModel, newModel)
        if source.type == "object" then
            local x,y,z = getElementPosition(source)
            source.streamable = false
            source.position = Vector3(2500,2500,2500)
            source.streamable = true
            source.position = Vector3(x,y,z)
        end
    end
)

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        for element in pairs(ghostedElements) do
            if isElement(element) then
                element.alpha = 255
            end
        end
    end
)