-- Slot Machine DX Panel (client)

local insideCol = nil
local spinning = false
local panelOpen = false

-- Panel méretek
local sx, sy = guiGetScreenSize()
local pw, ph = 520, 300
local px, py = (sx - pw) / 2, (sy - ph) / 2

-- Szimbólumok (ugyanazok, mint szerveren)
local symbols = { "🍒", "🍋", "🔔", "⭐", "💎" }

-- Reel anim state
local reels = {
  { cur = "🍒", stopAt = nil, stopTime = 0, stopped = false },
  { cur = "🍋", stopAt = nil, stopTime = 0, stopped = false },
  { cur = "🔔", stopAt = nil, stopTime = 0, stopped = false },
}
local lastTick = 0
local changeInterval = 60 -- ms, milyen gyorsan "vált" a szimbólum pörgés közben

-- Eredmény adatok
local result = nil -- {bet, mult, win, reels={...}}

local function randSymbol()
  return symbols[math.random(1, #symbols)]
end

-- colshape detect (object interaction verzióhoz)
addEventHandler("onClientColShapeHit", root, function(hitElement, matchingDim)
  if hitElement ~= localPlayer or not matchingDim then return end
  if getElementData(source, "slot:usecol") ~= true then return end
  insideCol = source
end)

addEventHandler("onClientColShapeLeave", root, function(hitElement, matchingDim)
  if hitElement ~= localPlayer or not matchingDim then return end
  if insideCol == source then insideCol = nil end
end)

local function openPanel()
  panelOpen = true
  result = nil
  showCursor(false)
end

local function closePanel()
  if spinning then return end
  panelOpen = false
  result = nil
end

local function startSpin()
  if spinning then return end
  if not insideCol or not isElement(insideCol) then return end

  openPanel()
  spinning = true
  result = nil

  -- reset reels
  for i = 1, 3 do
    reels[i].stopAt = nil
    reels[i].stopTime = 0
    reels[i].stopped = false
    reels[i].cur = randSymbol()
  end

  triggerServerEvent("slot:spin", resourceRoot, insideCol)
end

bindKey("e", "down", function()
  if not insideCol then return end
  startSpin()
end)

bindKey("escape", "down", function()
  if panelOpen then
    closePanel()
    cancelEvent()
  end
end)

-- DX rajzolás + anim
addEventHandler("onClientRender", root, function()
  -- Ha nincs panel, de közel vagy: kis hint
  if insideCol and not panelOpen then
    dxDrawText("NYERŐGÉP: Nyomd meg az E-t", 0, sy*0.80, sx, sy, tocolor(255,255,255,220), 1.0, "default-bold", "center", "top")
  end

  if not panelOpen then return end

  -- háttér
  dxDrawRectangle(px, py, pw, ph, tocolor(0, 0, 0, 180))
  dxDrawRectangle(px+6, py+6, pw-12, ph-12, tocolor(20, 20, 20, 220))

  dxDrawText("NYERŐGÉP", px, py+12, px+pw, py+40, tocolor(255,255,255,230), 1.4, "default-bold", "center", "top")

  -- Reel dobozok
  local rw, rh = 120, 110
  local gap = 20
  local startX = px + (pw - (rw*3 + gap*2)) / 2
  local ry = py + 70

  local now = getTickCount()
  if now - lastTick >= changeInterval then
    lastTick = now

    if spinning then
      for i = 1, 3 do
        if not reels[i].stopped then
          reels[i].cur = randSymbol()

          -- ha van beállított stopTime, és eljött az idő, megállítjuk a szerver eredményre
          if reels[i].stopTime > 0 and now >= reels[i].stopTime then
            reels[i].cur = reels[i].stopAt
            reels[i].stopped = true
          end
        end
      end

      -- ha mind megállt, vége a spinnek
      if reels[1].stopped and reels[2].stopped and reels[3].stopped then
        spinning = false
      end
    end
  end

  for i = 1, 3 do
    local x = startX + (i-1) * (rw + gap)
    dxDrawRectangle(x, ry, rw, rh, tocolor(0,0,0,160))
    dxDrawRectangle(x+3, ry+3, rw-6, rh-6, tocolor(35,35,35,230))
    dxDrawText(reels[i].cur, x, ry+10, x+rw, ry+rh, tocolor(255,255,255,240), 3.0, "default-bold", "center", "center")
  end

  -- Alsó infó
  local bet = 0
  if insideCol and isElement(insideCol) then
    bet = getElementData(insideCol, "slot:bet") or 0
  end

  local infoY = py + 200
  if spinning then
    dxDrawText("Pörgetés...", px, infoY, px+pw, infoY+30, tocolor(255,255,255,220), 1.1, "default-bold", "center", "top")
  else
    if result then
      local text = ("Tét: $%d   Szorzó: x%d   Nyeremény: $%d"):format(result.bet or bet, result.mult or 0, result.win or 0)
      dxDrawText(text, px, infoY, px+pw, infoY+30, tocolor(255,255,255,230), 1.05, "default-bold", "center", "top")

      if (result.win or 0) > 0 then
        dxDrawText("NYERTÉL!", px, infoY+32, px+pw, infoY+60, tocolor(80,220,255,240), 1.2, "default-bold", "center", "top")
      else
        dxDrawText("Nem nyert. Nyomj E-t újra!", px, infoY+32, px+pw, infoY+60, tocolor(255,200,120,240), 1.0, "default-bold", "center", "top")
      end
    else
      dxDrawText(("Tét: $%d"):format(bet), px, infoY, px+pw, infoY+30, tocolor(255,255,255,200), 1.0, "default-bold", "center", "top")
      dxDrawText("Nyomd meg az E-t a pörgetéshez", px, infoY+32, px+pw, infoY+60, tocolor(255,255,255,180), 1.0, "default-bold", "center", "top")
    end
  end

  dxDrawText("ESC: bezárás", px, py+ph-30, px+pw-12, py+ph-10, tocolor(255,255,255,120), 0.9, "default", "right", "center")
end)

-- szerver eredmény
addEvent("slot:spinResult", true)
addEventHandler("slot:spinResult", resourceRoot, function(ok, payload)
  if not panelOpen then
    -- ha valamiért nincs nyitva, nyissuk ki
    openPanel()
  end

  if not ok then
    spinning = false
    result = nil
    outputChatBox("[Slot] "..tostring(payload), 255, 80, 80)
    return
  end

  -- payload: { reels={a,b,c}, bet, mult, win }
  result = payload

  -- beállítjuk, hogy mikor álljanak meg a tárcsák
  local now = getTickCount()
  reels[1].stopAt = payload.reels[1]; reels[1].stopTime = now + 700
  reels[2].stopAt = payload.reels[2]; reels[2].stopTime = now + 1100
  reels[3].stopAt = payload.reels[3]; reels[3].stopTime = now + 1500

  reels[1].stopped = false
  reels[2].stopped = false
  reels[3].stopped = false
end)
