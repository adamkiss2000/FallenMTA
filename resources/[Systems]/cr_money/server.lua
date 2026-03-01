-- ==============================
-- CONFIG
-- ==============================

local MONEY_DATA_KEY = "char >> money"

-- ==============================
-- INTERNAL GET
-- ==============================

local function getPlayerMoney(player)
    if not isElement(player) then return 0 end
    return tonumber(getElementData(player, MONEY_DATA_KEY)) or 0
end

local function setPlayerMoney(player, amount)
    if not isElement(player) then return false end
    setElementData(player, MONEY_DATA_KEY, math.max(0, math.floor(amount)))
    return true
end

-- ==============================
-- HAS MONEY
-- ==============================

function hasMoney(player, amount, useBank)
    if not isElement(player) then return false end
    if not amount or amount <= 0 then return false end

    if not useBank then
        return getPlayerMoney(player) >= amount
    else
        if not exports.cr_bank then return false end
        local bankMoney = exports.cr_bank:getBankAccountMoney(player) or 0
        return bankMoney >= amount
    end
end

-- ==============================
-- TAKE MONEY
-- ==============================

function takeMoney(player, amount, useBank, ignoreCheck)
    if not isElement(player) then return false end
    if not amount or amount <= 0 then return false end

    amount = math.floor(amount)

    if not useBank then
        local current = getPlayerMoney(player)

        if current < amount and not ignoreCheck then
            return false
        end

        setPlayerMoney(player, current - amount)
        return true
    else
        if not exports.cr_bank then return false end

        if not ignoreCheck and not hasMoney(player, amount, true) then
            return false
        end

        exports.cr_bank:takeMoney(player, nil, amount)
        return true
    end
end

-- ==============================
-- GIVE MONEY
-- ==============================

function giveMoney(player, amount, useBank)
    if not isElement(player) then return false end
    if not amount or amount <= 0 then return false end

    amount = math.floor(amount)

    if not useBank then
        local current = getPlayerMoney(player)
        setPlayerMoney(player, current + amount)
        return true
    else
        if not exports.cr_bank then return false end
        exports.cr_bank:giveMoney(player, nil, amount)
        return true
    end
end