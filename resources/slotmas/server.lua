-- Slot Machine (object interaction) - server

local POS = Vector3(2401.7424316406, 2538.1499023438, 21.875)
local ROT = Vector3(0, 0, 90)   -- ha más irányba nézzen, ezt állítsd
local INT, DIM = 0, 0

-- Ide rakj "slot machine"-nek kinéző object ID-t, amit használtok.
-- Default: egy "arcade/cabinet" jellegű prop (cserélhető).
local SLOT_OBJECT_ID = 2325

local USE_RADIUS = 1.4
local BET = 0
local COOLDOWN_MS = 2500

local SYMBOLS = {
  { id = "🍒", weight = 40 },
  { id = "🍋", weight = 30 },
  { id = "🔔", weight = 18 },
  { id = "⭐", weight = 9  },
  { id = "💎", weight = 3  },
}
local TRIPLE_MULT = { ["🍒"]=2, ["🍋"]=3, ["🔔"]=5, ["⭐"]=12, ["💎"]=50 }
local PAIR_MULT   = { ["🍒"]=1, ["🍋"]=1, ["🔔"]=2, ["⭐"]=3,  ["💎"]=10 }

local lastSpinTick = {}

local function weightedPick()
  local total = 0
  for _, s in ipairs(SYMBOLS) do total = total + s.weight end
  local r = math.random() * total
  local acc = 0
  for _, s in ipairs(SYMBOLS) do
    acc = acc + s.weight
    if r <= acc then return s.id end
  end
  return SYMBOLS[#SYMBOLS].id
end

local function calcMultiplier(a,b,c)
  if a == b and b == c then return TRIPLE_MULT[a] or 0 end
  if a == b then return PAIR_MULT[a] or 0 end
  if a == c then return PAIR_MULT[a] or 0 end
  if b == c then return PAIR_MULT[b] or 0 end
  return 0
end

-- Objekt + colshape
local machineObj = createObject(SLOT_OBJECT_ID, POS.x, POS.y, POS.z, ROT.x, ROT.y, ROT.z)
setElementInterior(machineObj, INT)
setElementDimension(machineObj, DIM)
setObjectBreakable(machineObj, false)

local useCol = createColSphere(POS.x, POS.y, POS.z, USE_RADIUS)
setElementInterior(useCol, INT)
setElementDimension(useCol, DIM)

-- azonosító (szinkronos)
setElementData(useCol, "slot:usecol", true)
setElementData(useCol, "slot:bet", BET)
setElementData(useCol, "slot:object", machineObj)

addEvent("slot:spin", true)
addEventHandler("slot:spin", root, function(colEl)
  local player = client
  if not isElement(player) then return end
  if not isElement(colEl) or getElementType(colEl) ~= "colshape" then return end
  if getElementData(colEl, "slot:usecol") ~= true then return end

  if not isElementWithinColShape(player, colEl) then
    triggerClientEvent(player, "slot:spinResult", resourceRoot, false, "Nem vagy elég közel a nyerőgéphez.")
    return
  end

  local now = getTickCount()
  local last = lastSpinTick[player] or 0
  if now - last < COOLDOWN_MS then
    triggerClientEvent(player, "slot:spinResult", resourceRoot, false, "Várj egy pillanatot a következő pörgetésig.")
    return
  end
  lastSpinTick[player] = now

  if getPlayerMoney(player) < BET then
    triggerClientEvent(player, "slot:spinResult", resourceRoot, false, "Nincs elég pénzed. (Tét: $"..BET..")")
    return
  end

  takePlayerMoney(player, BET)

  local a, b, c = weightedPick(), weightedPick(), weightedPick()
  local mult = calcMultiplier(a,b,c)
  local win = BET * mult
  if win > 0 then givePlayerMoney(player, win) end

  triggerClientEvent(player, "slot:spinResult", resourceRoot, true, {
    reels = {a,b,c},
    bet = BET,
    mult = mult,
    win = win
  })
end)

addEventHandler("onPlayerQuit", root, function()
  lastSpinTick[source] = nil
end)

-- Ha dim/int szokott változni a szervereden, ezzel a parancsal a játékos dim/int-jére állítod a gépet:
addCommandHandler("slotfix", function(p)
  if not isElement(p) then return end
  local dim = getElementDimension(p)
  local int = getElementInterior(p)
  setElementDimension(machineObj, dim)
  setElementInterior(machineObj, int)
  setElementDimension(useCol, dim)
  setElementInterior(useCol, int)
  outputChatBox("[Slot] Gép dim/int beállítva: DIM="..dim.." INT="..int, p, 0, 255, 0)
end)
