local devSerials = {}
local devNames = {}

-- ==============================
-- Dev serial betöltés DB-ből
-- ==============================

function loadDevSerials()
    devSerials = {}
    devNames = {}

    if not exports.cr_mysql then
        outputServerLog("[cr_dev] ERROR: cr_mysql not found.")
        return
    end

    local query = exports.cr_mysql:query("SELECT serial, name FROM devserials")

    if query and type(query) == "table" then
        for _, row in ipairs(query) do
            devSerials[row.serial] = true
            devNames[row.serial] = row.name
        end
    end

    outputServerLog("[cr_dev] Dev serials loaded: "..tostring(#query or 0))
end

addEventHandler("onResourceStart", resourceRoot, loadDevSerials)

-- ==============================
-- Client cache kérés
-- ==============================

addEvent("cr_dev:requestCache", true)
addEventHandler("cr_dev:requestCache", root,
    function()
        if client then
            triggerClientEvent(client, "cr_dev:receiveCache", client, devSerials, devNames)
        end
    end
)

-- ==============================
-- Developer ellenőrzés (server)
-- ==============================

function isPlayerDeveloper(player)
    if not isElement(player) then return false end

    local serial = getPlayerSerial(player)
    if devSerials[serial] then
        return true, devNames[serial]
    end

    return false
end