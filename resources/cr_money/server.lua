local connection = exports.cr_mysql:getConnection(resource)

local moneyCache = {}

-- ===========================
-- CHARACTER LOAD
-- ===========================

addEvent("character:setActive", true)
addEventHandler("character:setActive", root,
    function(charId)
        local player = client
        if not isElement(player) then return end

        dbQuery(function(qh)
            local result = dbPoll(qh, 0)
            if #result == 0 then return end

            local data = result[1]
            moneyCache[player] = {
                charId = charId,
                money = tonumber(data.money) or 0,
                bank = tonumber(data.bank_money) or 0
            }
        end, connection,
        "SELECT money, bank_money FROM characters WHERE id = ?",
        charId)
    end
)

-- ===========================
-- GETTERS
-- ===========================

function getMoney(player)
    if moneyCache[player] then
        return moneyCache[player].money
    end
    return 0
end

function getBankMoney(player)
    if moneyCache[player] then
        return moneyCache[player].bank
    end
    return 0
end

-- ===========================
-- SETTERS
-- ===========================

function setMoney(player, amount)
    if not moneyCache[player] then return false end
    amount = math.max(0, math.floor(amount))

    moneyCache[player].money = amount

    dbExec(connection, "UPDATE characters SET money=? WHERE id=?",
        amount,
        moneyCache[player].charId
    )

    return true
end

function setBankMoney(player, amount)
    if not moneyCache[player] then return false end
    amount = math.max(0, math.floor(amount))

    moneyCache[player].bank = amount

    dbExec(connection, "UPDATE characters SET bank_money=? WHERE id=?",
        amount,
        moneyCache[player].charId
    )

    return true
end

-- ===========================
-- ADD / TAKE
-- ===========================

function giveMoney(player, amount)
    if not moneyCache[player] then return false end
    amount = math.floor(amount)
    if amount <= 0 then return false end

    return setMoney(player, moneyCache[player].money + amount)
end

function takeMoney(player, amount)
    if not moneyCache[player] then return false end
    amount = math.floor(amount)
    if amount <= 0 then return false end

    if moneyCache[player].money < amount then
        return false
    end

    return setMoney(player, moneyCache[player].money - amount)
end

function giveBankMoney(player, amount)
    if not moneyCache[player] then return false end
    amount = math.floor(amount)
    if amount <= 0 then return false end

    return setBankMoney(player, moneyCache[player].bank + amount)
end

function takeBankMoney(player, amount)
    if not moneyCache[player] then return false end
    amount = math.floor(amount)
    if amount <= 0 then return false end

    if moneyCache[player].bank < amount then
        return false
    end

    return setBankMoney(player, moneyCache[player].bank - amount)
end

-- ===========================
-- CLEANUP
-- ===========================

addEventHandler("onPlayerQuit", root,
    function()
        moneyCache[source] = nil
    end
)

addEventHandler("onResourceStop", resourceRoot,
    function()
        for player, data in pairs(moneyCache) do
            if isElement(player) then
                dbExec(connection,
                    "UPDATE characters SET money=?, bank_money=? WHERE id=?",
                    data.money,
                    data.bank,
                    data.charId
                )
            end
        end
    end
)
