local devSerials = {}
local devNames = {}

-- ==============================
-- Cache fogadása
-- ==============================

addEvent("cr_dev:receiveCache", true)
addEventHandler("cr_dev:receiveCache", root,
    function(serialTable, nameTable)
        devSerials = serialTable or {}
        devNames = nameTable or {}
    end
)

-- ==============================
-- Cache kérés induláskor
-- ==============================

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        triggerServerEvent("cr_dev:requestCache", localPlayer)
    end
)

-- ==============================
-- Developer ellenőrzés (client)
-- ==============================

function getPlayerDeveloper(player)
    if not isElement(player) then return false end

    local serial = getElementData(player, "mtaserial") or getPlayerSerial(player)

    if devSerials[serial] then
        return true, devNames[serial]
    end

    return false
end