local percentTime = 62.5
local idCache = {}
local virtualSkins = {}
virtualToAllocatedSkinID = {}

function loadModells()
    if not localPlayer:getData("modells >> loaded") then return end
    if not localPlayer:getData("vehicles >> loaded") then return end
    if loadingStarted then return end
    loadingStarted = true

    localPlayer:setData("skins >> loading", true)
    engineSetAsynchronousLoading(false, false)

    local loadCache = {}
    for _, v in ipairs(cache) do
        local model = v[1]
        if tonumber(model) or fromJSON(tostring(model)) then
            table.insert(loadCache, v)
        end
    end

    -- virtual skin slotok
    for _, v in ipairs(cache) do
        local model, _, typ, _, isVirtualSkin = unpack(v)
        if isVirtualSkin and typ == "txd" then
            local allocated = engineRequestModel("ped")
            virtualSkins[model] = allocated
            virtualToAllocatedSkinID[model] = allocated
        end
    end

    local maxs = #loadCache
    local allStart = 0
    local now = getTickCount()

    exports["cr_infobox"]:addBox(
        "skins",
        "Skinek betöltése: "..maxs.."/0",
        "skins",
        {2, {maxs, 0}}
    )

    startTimer = setTimer(function()

        if #loadCache == 0 then
            localPlayer:setData("skins >> loading", false)
            localPlayer:setData("skins >> loaded", true)

            local seconds = (getTickCount() - now) / 1000
            outputDebugString(
                "Loading succesfully finished, #"..allStart.." skins loaded in #"..seconds.." seconds!",
                0, 20, 87, 255
            )

            killTimer(startTimer)

            -- 🔑 KRITIKUS: playerek frissítése
            for _, p in ipairs(getElementsByType("player", root, true)) do
                local skin = p:getData("char >> skin")
                if tonumber(skin) then
                    setElementSpecialModel(p, skin)
                end
            end

            triggerEvent("builder>loadWeapons", localPlayer, localPlayer)
            return
        end

        local v = table.remove(loadCache, 1)
        local model, fileSrc, typ, _, isVirtualSkin = unpack(v)

        if isVirtualSkin then
            model = virtualSkins[model]
        end

        if tonumber(model) then
            if typ == "txd" then
                local txd = engineLoadTXD(fileSrc)
                if txd then engineImportTXD(txd, model) end

            elseif typ == "dff" then
                local dff = engineLoadDFF(fileSrc, model)
                if dff then engineReplaceModel(dff, model) end

            elseif typ == "col" then
                local col = engineLoadCOL(fileSrc)
                if col then engineReplaceCOL(col, model) end
            end

        elseif fromJSON(tostring(model)) then
            local models = fromJSON(tostring(model))
            for _, m in ipairs(models) do
                if typ == "txd" then
                    local txd = engineLoadTXD(fileSrc)
                    if txd then engineImportTXD(txd, m) end

                elseif typ == "dff" then
                    local dff = engineLoadDFF(fileSrc, m)
                    if dff then engineReplaceModel(dff, m) end

                elseif typ == "col" then
                    local col = engineLoadCOL(fileSrc)
                    if col then engineReplaceCOL(col, m) end
                end
            end
        end

        allStart = allStart + 1
        exports["cr_infobox"]:updateBoxDetails("skins", "custom2.details", {maxs, allStart})
        exports["cr_infobox"]:updateBoxDetails(
            "skins",
            "msg",
            "Skinek betöltése: "..maxs.."/"..allStart
        )

    end, percentTime, 0)
end

addEvent("builder>loadSkins", true)
addEventHandler("builder>loadSkins", root, loadModells)

-- 🔑 EZ TESZI RÁ TÉNYLEGESEN A SKINT A PLAYERRE
function setElementSpecialModel(player, skin)
    if not tonumber(skin) then return end

    if isVirtualSkin(skin) and virtualToAllocatedSkinID[skin] then
        player:setModel(virtualToAllocatedSkinID[skin])
    else
        player:setModel(skin)
    end
end

addEventHandler("onClientElementDataChange", root,
    function(dName, _, newValue)
        if dName == "char >> skin" or dName == "ped >> skin" or dName == "char >> dutyskin" then
            setElementSpecialModel(source, newValue)
        end
    end
)

addEventHandler("onClientPlayerSpawn", root,
    function()
        setElementSpecialModel(source, source:getData("char >> skin"))
    end
)

addEventHandler("onClientElementStreamIn", root,
    function()
        if source.type == "player" then
            local skin = source:getData("char >> skin")
            if tonumber(source:getData("char >> dutyskin")) then
                skin = tonumber(source:getData("char >> dutyskin"))
            end
            setElementSpecialModel(source, skin)

        elseif source.type == "ped" then
            setElementSpecialModel(source, source:getData("ped >> skin"))
        end
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        for _, id in pairs(virtualToAllocatedSkinID) do
            engineFreeModel(id)
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        if localPlayer:getData("vehicles >> loaded") then
            loadModells()
        end
    end
)