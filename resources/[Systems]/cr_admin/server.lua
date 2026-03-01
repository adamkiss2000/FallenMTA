local ADMIN_DATA_KEY = "admin >> level"

-- ==============================
-- GET ADMIN LEVEL
-- ==============================

function getAdminLevel(player)
    if not isElement(player) then return 0 end
    return tonumber(getElementData(player, ADMIN_DATA_KEY)) or 0
end

-- ==============================
-- CHECK ADMIN
-- ==============================

function isPlayerAdmin(player, requiredLevel)
    if not isElement(player) then return false end

    requiredLevel = requiredLevel or 1
    return getAdminLevel(player) >= requiredLevel
end

-- ==============================
-- ADMIN CHAT
-- ==============================

function sendAdminMessage(sourcePlayer, text, requiredLevel)
    if not isElement(sourcePlayer) then return false end
    if not text or text == "" then return false end

    requiredLevel = requiredLevel or 1

    local sourceLevel = getAdminLevel(sourcePlayer)
    if sourceLevel < requiredLevel then
        return false
    end

    local name = getPlayerName(sourcePlayer)
    local formatted = "#FF6600[ADMIN] #FFFFFF"..name..": "..text

    for _, player in ipairs(getElementsByType("player")) do
        if getAdminLevel(player) >= requiredLevel then
            outputChatBox(formatted, player, 255, 255, 255, true)
        end
    end

    return true
end

-- ==============================
-- /a ADMIN CHAT COMMAND
-- ==============================

addCommandHandler("a",
    function(player, cmd, ...)
        if not isPlayerAdmin(player, 1) then
            outputChatBox("Nincs jogosultságod.", player, 255, 0, 0)
            return
        end

        local message = table.concat({...}, " ")
        if message == "" then return end

        sendAdminMessage(player, message, 1)
    end
)