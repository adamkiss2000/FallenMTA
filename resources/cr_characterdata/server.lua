local connection = exports.cr_mysql:getConnection(resource)

local SAVE_INTERVAL = 60 * 1000 -- 1 perc

function getDB()
    return connection
end

-- =============================
-- SPAWN UTÁNI KARAKTER BETÖLTÉS
-- =============================

addEventHandler("onPlayerSpawn", root,
    function()
        if not getElementData(source, "acc:id") then return end
        local charId = getElementData(source, "char:id")
        if not charId then return end

        dbQuery(function(qh)
            local result = dbPoll(qh, 0)
            if #result == 0 then return end

            local char = result[1]

            setElementHealth(source, char.health)
            setPedArmor(source, char.armor)
        end,
        getDB(),
        "SELECT health, armor FROM characters WHERE id = ?",
        charId)
    end
)

-- =============================
-- KARAKTER AKTÍVÁLÁS
-- =============================

addEvent("character:setActive", true)
addEventHandler("character:setActive", root,
    function(charId)
        setElementData(client, "char:id", charId)
    end
)

-- =============================
-- SAVE FUNCTION
-- =============================

function saveCharacter(player)
    if not isElement(player) then return end
    if not getElementData(player, "loggedIn") then return end

    local charId = getElementData(player, "char:id")
    if not charId then return end

    local x, y, z = getElementPosition(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)
    local health = getElementHealth(player)
    local armor = getPedArmor(player)
    local skin = getElementModel(player)

    dbExec(getDB(), [[
        UPDATE characters
        SET pos_x = ?, pos_y = ?, pos_z = ?,
            interior = ?, dimension = ?,
            health = ?, armor = ?, skin = ?
        WHERE id = ?
    ]],
    x, y, z,
    interior, dimension,
    health, armor, skin,
    charId)
end

-- =============================
-- AUTOSAVE
-- =============================

setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        saveCharacter(player)
    end
    outputDebugString("[CharacterData] AutoSave completed.")
end, SAVE_INTERVAL, 0)

-- =============================
-- QUIT SAVE
-- =============================

addEventHandler("onPlayerQuit", root,
    function()
        saveCharacter(source)
    end
)

-- =============================
-- RESOURCE STOP SAVE
-- =============================

addEventHandler("onResourceStop", resourceRoot,
    function()
        for _, player in ipairs(getElementsByType("player")) do
            saveCharacter(player)
        end
        outputDebugString("[CharacterData] All characters saved on stop.")
    end
)
