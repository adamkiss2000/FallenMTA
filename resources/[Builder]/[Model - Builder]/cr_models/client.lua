local maxStartPerTime = 1
local percentTime = 125
local idCache = {}

function loadModells()
    if loadingStarted then return end

    localPlayer:setData('modells >> loading', true)

    local turnableCache = exports['cr_json']:jsonGET("modpanel/turnabled", true, {}) or {}
    loadingStarted = true
    engineSetAsynchronousLoading(false, false)

    local loadCache = {}

    for _, v in ipairs(cache) do
        local model, fileSrc, typ, isGlass, specialLodDistance = unpack(v)

        if tonumber(model) then
            if not idCache[tostring(model)] then
                idCache[tostring(model)] = {}
            end
            table.insert(idCache[tostring(model)], v)

            if not turnableCache[tostring(model)] then
                table.insert(loadCache, v)
            end

        elseif fromJSON(tostring(model)) then
            table.insert(loadCache, v)
        end
    end

    local maxs = #loadCache
    allStart = 0
    now = getTickCount()

    exports['cr_infobox']:addBox(
        "models",
        "Modellek betöltése: "..maxs.."/"..allStart,
        "models",
        {2, {maxs, allStart}}
    )

    startTimer = setTimer(function()
        if #loadCache == 0 then
            localPlayer:setData('modells >> loading', false)
            localPlayer:setData('modells >> loaded', true)

            local seconds = (getTickCount() - now) / 1000
            outputDebugString(
                "Loading succesfully finished, #"..allStart.." models loaded in #"..seconds.." seconds!",
                0, 20, 87, 255
            )

            killTimer(startTimer)
            triggerEvent("builder>loadVehicles", localPlayer, localPlayer)
            return
        end

        local v = loadCache[1]
        local model, fileSrc, typ, isGlass, specialLodDistance = unpack(v)

        if tonumber(model) then
            if typ == "txd" then
                local txd = engineLoadTXD(fileSrc)
                engineImportTXD(txd, model)

            elseif typ == "dff" then
                local dff = engineLoadDFF(fileSrc, model)
                if dff then
                    engineReplaceModel(dff, model, isGlass)
                else
                    outputDebugString("[MODELS] DFF load failed: "..tostring(fileSrc), 1)
                end

            elseif typ == "col" then
                local col = engineLoadCOL(fileSrc)
                engineReplaceCOL(col, model)
            end

            if tonumber(specialLodDistance) then
                engineSetModelLODDistance(model, specialLodDistance)
            end

        elseif fromJSON(tostring(model)) then
            local modells = fromJSON(tostring(model))
            for _, m in ipairs(modells) do
                if typ == "txd" then
                    local txd = engineLoadTXD(fileSrc)
                    engineImportTXD(txd, m)

                elseif typ == "dff" then
                    local dff = engineLoadDFF(fileSrc, m)
                    if dff then
                        engineReplaceModel(dff, m, isGlass)
                    end

                elseif typ == "col" then
                    local col = engineLoadCOL(fileSrc)
                    engineReplaceCOL(col, m)
                end

                if tonumber(specialLodDistance) then
                    engineSetModelLODDistance(m, specialLodDistance)
                end
            end
        end

        table.remove(loadCache, 1)
        allStart = allStart + 1

        exports['cr_infobox']:updateBoxDetails("models", "custom2.details", {maxs, allStart})
        exports['cr_infobox']:updateBoxDetails("models", "msg", "Modellek betöltése: "..maxs.."/"..allStart)

    end, percentTime, 0)
end

addEvent("builder>loadModells", true)
addEventHandler("builder>loadModells", root, loadModells)

addEventHandler("onClientResourceStart", resourceRoot, loadModells)