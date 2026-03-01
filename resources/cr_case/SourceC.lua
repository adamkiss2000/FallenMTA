local Root = getRootElement()

local FileKeys = {
	["1"] = "3xbM4kzd",
	["2"] = "FRQ2llhA",
	["3"] = "yyfbVVfV",
	["4"] = "klsUPV0D",
	["Bg"] = "2fryf5ZT",
	["Body"] = "kp7QJlzf",
	["Eye"] = "Sa6S8Ukl",
	["Eyebg"] = "9DzScNcf",
	["Eyeshut"] = "N2UHWkL3",
	["Glass"] = "myS4InLu",
	["Head"] = "vklZ7vWx",
	["Head2"] = "Tz4VF6FR",
	["Hoho"] = "YiISXeUZ",
	["Ibg"] = "atkBICrC",
	["ItemHover"] = "inDeax1V",
	["Mouth"] = "WB4cNhC3",
	["Mouth2"] = "JuqmXDpW",
	["Shadow_body"] = "DpraVWOZ",
	["Shadow_head"] = "OCmxmhjO",
	["Win"] = "xCWiHHl0",
	["Zzz"] = "8s8dRfaW",

}

function reMap(InValue, InMin, InMax, OutMin, OutMax)
	return (InValue - InMin) * (OutMax - OutMin) / (InMax - InMin) + OutMin
end

local ScreenX, ScreenY = guiGetScreenSize()
local ResponsiveMultipler = reMap(ScreenX, 1024, 1920, 0.75, 1)

function Resp(Value)
	return Value * ResponsiveMultipler
end

function Respc(Value)
	return math.ceil(Value * ResponsiveMultipler)
end

function TeaDecodeBinary(Data, Key)
    return decodeString("base64", teaDecode(Data, Key))
end

function UnlockFile(Path, Key)
	local File = fileOpen(Path)
	local Size = fileGetSize(File)

	local EncodedData = fileRead(File, Size)
	fileClose(File)

	local Data = TeaDecodeBinary(EncodedData, Key)
	
	return Data
end

---------------------------------------------------------------------------------------------

local FrameTime = getTickCount()

local GameState = false
local GameTimer = false
local GameOpacity = 0
local GameMainFont = false

local TextureElements = {}
local TexturesToBeLoaded = {
	["Bg"]          = true,
	["Body"]        = true,
	["Head"]        = true,
	["Head2"]       = true,
	["Eyebg"]       = true,
	["Eyeshut"]     = true,
	["Eye"]         = true,
	["Glass"]       = true,
	["Mouth"]       = true,
	["Mouth2"]      = true,
	["Shadow_body"] = true,
	["Shadow_head"] = true,
	["Zzz"]         = true,
	["Hoho"]        = true,
	["Win"]         = true,
	["ItemHover"]   = true,
	["Ibg"]         = true,
	["1"]           = true,
	["2"]           = true,
	["3"]           = true,
	["4"]           = true,
}

local BasePosnX = ScreenX / 2
local BasePosnY = 0

local SantaSizeX = Respc(500)
local SantaSizeY = Respc(372)
local SantaPosnX = BasePosnX - SantaSizeX / 2
local SantaPosnY = BasePosnY + Respc(102)

local LogoSizeX = Respc(700)
local LogoSizeY = Respc(250)
local LogoPosnX = BasePosnX - LogoSizeX / 2
local LogoPosnY = BasePosnY + Respc(265)

local EyeSizeX = Respc(6)
local EyeSizeY = Respc(6)
local EyeSpriteSizeX = Respc(6)
local EyeSpriteSizeY = Respc(6)
local EyeRadius = Respc(6)
local EyesState = false
local EyesViewAngle = 0
local EyesLastBlink = 0
local EyesNextBlink = math.random(1500, 3000)
local EyesBlinkTwice = false

local HeadInterpolation = {getTickCount(), true}
local HeadRotation = 0
local HeadRotationCenterX = -Respc(75)
local HeadRotationCenterY = 0

local SnoreOriginX = SantaPosnX + Respc(268)
local SnoreOriginY = SantaPosnY + Respc(143)
local SnoreTimer = 0
local SnoreSound = false
local SnoreState = false

local HohohoTimer = false
local HohohoCount = 0
local HohohoSoundPlayed = false
local HohohoState = false

local SymbolSizeX = Respc(36)
local SymbolSizeY = Respc(36)
local SymbolTable = {}

local BgPreMusic = false
local BgWinMusic = false

local CarouselItemsNum = 11
local CarouselItemSpacing = 1 / (CarouselItemsNum - 1)
local CarouselItems = {}
local CarouSelFocusItem = false
local CarouSelFirstVisibleItem = 1
local CarouselItemSensor = 0

local CarouselTrackedItem = false
local CarouselTrackedItemPosition = {0, 0}

local CarouselStartTimer = false
local CarouSelFinishTimer = false

local CarouselDistance = 0
local CarouselDestination = 0
local CarouselEasing = false

local ItemsLineSizeX = Respc(650)
local ItemsLineSizeY = Respc(50)
local ItemsLinePosnX = LogoPosnX + (LogoSizeX - ItemsLineSizeX) / 2
local ItemsLinePosnY = LogoPosnY + Respc(174)

local SnowCanvasSizeX = Respc(780)
local SnowCanvasSizeY = ItemsLinePosnY + ItemsLineSizeY + Respc(40)
local SnowCanvasPosnX = (ScreenX - SnowCanvasSizeX) / 2
local SnowCanvasPosnY = 0
local SnowflakeParticles = {}

---------------------------------------------------------------------------------------------

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		for TextureName, ShouldBeLoaded in pairs(TexturesToBeLoaded) do
			if ShouldBeLoaded then
				--local FilePath = UnlockFile("Files/Images/" .. TextureName .. ".png", TextureName)
				local FilePath = "Files/Images/" .. TextureName .. ".png", FileKeys[TextureName]

				if fileExists("Files/Images/" .. TextureName .. ".png") then
					local TextureElement = dxCreateTexture(FilePath, "argb", false, "clamp")

					if isElement(TextureElement) then
						TextureElements[TextureName] = TextureElement
					end
				else
					outputDebugString("File (" .. FilePath .. ") not exists.", 2)
				end
			end
		end
	end
)

---------------------------------------------------------------------------------------------

function TryToStartSantaOpening(DbID)
	if GameState then
		return false
	end

	FrameTime = getTickCount()

	GameState = "FadeIn"
	GameTimer = FrameTime
	GameOpacity = 0
	GameMainFont = dxCreateFont("Files/Fonts/BebasNeueRegular.otf", Respc(28), false, "antialiased")

	SnoreSound = playSound("Files/Sounds/Snore.mp3")
	SnoreTimer = FrameTime
	SnoreState = false

	HohohoTimer = false
	HohohoCount = 0
	HohohoSoundPlayed = false
	HohohoState = false

	EyesState = "Sleep"
	EyesViewAngle = 0

	addEventHandler("onClientPreRender", Root, PreRenderSantaOpen)
	addEventHandler("onClientRender", Root, RenderSantaOpen)

	StartSantaOpening()

	--if DbID then
	--	triggerServerEvent("getConnection", localPlayer, localPlayer, "dbID", DbID, 1, "octansBossMTA")
	--end

	return true
end

function StartSantaOpening()
	local NumberOfSnowflakes = 40
	local SnowflakeTypeCycle = 1

	for i = 1, NumberOfSnowflakes do
		SnowflakeParticles[i] = CreateSnowflake(SnowflakeTypeCycle)
		SnowflakeTypeCycle = SnowflakeTypeCycle % 4 + 1
	end

	table.sort(SnowflakeParticles,
		function (A, B)
			return A.DepthFactor < B.DepthFactor
		end
	)

	CarouselItems = {}
	CarouSelFocusItem = false
	CarouSelFirstVisibleItem = 1
	CarouselTrackedItem = false

	CarouselStartTimer = FrameTime + 3866 * math.random(2, 3)
	CarouSelFinishTimer = false

	CarouselDistance = 0
	CarouselDestination = math.random(100, 200)
	CarouselItemSensor = 0

	for I = 1, CarouselItemsNum + 1 do
		CarouselItems[I] = ChooseRandomItem()
	end

	exports.cr_chat:createMessage(localPlayer, "kinyit egy ládát", 1)
end

function CloseSantaOpening()
	if not GameState then
		return
	end

	removeEventHandler("onClientPreRender", Root, PreRenderSantaOpen)
	removeEventHandler("onClientRender", Root, RenderSantaOpen)

	if GameMainFont then
		if isElement(GameMainFont) then
			destroyElement(GameMainFont)
		end
		GameMainFont = nil
	end

	CarouselItems = {}
	SymbolTable = {}
	SnowflakeParticles = {}

	if BgPreMusic then
		if isElement(BgPreMusic) then
			destroyElement(BgPreMusic)
		end
		BgPreMusic = nil
	end

	if BgWinMusic then
		if isElement(BgWinMusic) then
			destroyElement(BgWinMusic)
		end
		BgWinMusic = nil
	end

	GameState = false
end

---------------------------------------------------------------------------------------------

function PreRenderSantaOpen(DeltaTime)
	DeltaTime = DeltaTime / 1000

	if CarouselStartTimer then
		local ElapsedTime = FrameTime - CarouselStartTimer

		if ElapsedTime > 0 then
			local ElapsedFraction = ElapsedTime / 24000

			if not CarouselEasing then
				CarouselEasing = CreateBezierEasing(0.2, 0, 0.2, 1)
			end

			CarouselDistance = CarouselDestination * CarouselEasing(ElapsedFraction)

			if ElapsedFraction >= 1 then
				CarouselDistance = CarouselDestination
				CarouselStartTimer = false
				CarouSelFinishTimer = FrameTime
			end

			if EyesState == "Sleep" then
				EyesLastBlink = FrameTime
				EyesNextBlink = FrameTime + math.random(1500, 3000)
				EyesState = "Open"
			end

			if SnoreTimer then
				SnoreTimer = false
				SnoreState = false

				if SnoreSound then
					if isElement(SnoreSound) then
						destroyElement(SnoreSound)
					end

					SnoreSound = nil
				end
			end

			if not HohohoTimer then
				HohohoTimer = FrameTime + math.random(2500, 5000)
			end

			if GameState == "FadedIn" then
				GameState = "StartMusic"

				BgPreMusic = playSound("Files/Sounds/Music.mp3", true)
				BgWinMusic = playSound("Files/Sounds/Music2.mp3", true)

				if isElement(BgPreMusic) then
					setSoundVolume(BgPreMusic, 0)
				end

				if isElement(BgWinMusic) then
					setSoundVolume(BgWinMusic, 0)
				end
			elseif GameState == "StartMusic" then
				if isElement(BgPreMusic) then
					if ElapsedTime < 500 then
						setSoundVolume(BgPreMusic, ElapsedTime / 500)
					else
						setSoundVolume(BgPreMusic, 1)
					end
				end
			end
		end
	end

	if CarouselTrackedItemPosition then
		local EyeContainerX = SantaPosnX + SantaSizeX / 2
		local EyeContainerY = SantaPosnY + SantaSizeY / 2

		local TargetViewAngle = math.atan2(
			CarouselTrackedItemPosition[2] - EyeContainerY,
			CarouselTrackedItemPosition[1] - EyeContainerX
		)

		local CurrentAngle = EyesViewAngle

		if TargetViewAngle - CurrentAngle > math.pi then
			TargetViewAngle = TargetViewAngle - 2 * math.pi
		elseif CurrentAngle - TargetViewAngle > math.pi then
			CurrentAngle = CurrentAngle - 2 * math.pi
		end

		EyesViewAngle = CurrentAngle + (TargetViewAngle - CurrentAngle) * DeltaTime * 4
	end

	UpdateSnowflakes(DeltaTime)
end

function RenderSantaOpen()
	FrameTime = getTickCount()

	if GameTimer then
		local ElapsedTime = FrameTime - GameTimer

		if ElapsedTime > 0 then
			if GameState == "FadeIn" then
				local ElapsedFraction = ElapsedTime / 500

				GameOpacity = getEasingValue(ElapsedFraction, "InOutQuad")

				if isElement(BgPreMusic) then
					setSoundVolume(BgPreMusic, GameOpacity)
				end

				if ElapsedFraction >= 1 then
					GameOpacity = 1
					GameTimer = false
					GameState = "FadedIn"
				end
			elseif GameState == "FadeOut" then
				local ElapsedFraction = ElapsedTime / 500

				GameOpacity = 1 - getEasingValue(ElapsedFraction, "InOutQuad")

				if isElement(BgWinMusic) then
					setSoundVolume(BgWinMusic, GameOpacity)
				end

				if ElapsedFraction >= 1 then
					CloseSantaOpening()
					return
				end
			end
		end
	end

	RenderSnowflakes()
	RenderTheSanta()
	RenderMinigame()
end

function CreateSnowflake(snowflakeType)
	local Self = {}

	Self.TextureName = tostring(snowflakeType)
	Self.DepthFactor = math.random(0, 100) / 100

	Self.SizeX = Respc(24) * (1 - Self.DepthFactor) + Respc(64) * Self.DepthFactor
	Self.SizeY = Self.SizeX

	Self.PositionX = math.random(SnowCanvasPosnX + Self.SizeX, SnowCanvasPosnX + SnowCanvasSizeX) - Self.SizeX / 2
	Self.PositionY = math.random(SnowCanvasPosnY, SnowCanvasPosnY + SnowCanvasSizeY) - Self.SizeY / 2

	Self.StrafeSpeed = 5 * (1 - Self.DepthFactor) + 20 * Self.DepthFactor
	Self.StrafeChangeRate = math.random(35, 75) / 100
	Self.StrafeAmount = Self.StrafeChangeRate

	Self.RotationDeg = 0
	Self.OpacityFactor = 0.4 * (1 - Self.DepthFactor) + 1 * Self.DepthFactor

	Self.WindForce = math.random(20, 100) / 100
	Self.WindDirection = math.random() < 0.5 and -1 or 1

	Self.DistanceFactor = 0

	return Self
end

function UpdateSnowflakes(DeltaTime)
	for I = #SnowflakeParticles, 1, -1 do
		local Value = SnowflakeParticles[I]

		if Value then
			local StrafeX = math.cos(Value.StrafeAmount)
			local StrafeY = math.sin(math.pi / 2)

			Value.WindForce = Value.WindForce + 0.1 * Value.WindDirection * DeltaTime

			if Value.WindForce > 1.2 then
				Value.WindForce = 1.2
				Value.WindDirection = -1
			elseif Value.WindForce < 0.2 then
				Value.WindForce = 0.2
				Value.WindDirection = 1
			end

			StrafeX = StrafeX * (1 - Value.WindForce)
			StrafeY = StrafeY * Value.WindForce

			Value.RotationDeg = 72 * StrafeX * math.rad(Value.SizeX)
			Value.StrafeAmount = Value.StrafeAmount + Value.StrafeChangeRate * DeltaTime

			StrafeX = StrafeX * Value.StrafeSpeed
			StrafeY = StrafeY * Value.StrafeSpeed

			if DebugMode then
				dxDrawLine(Value.PositionX, Value.PositionY, Value.PositionX + StrafeX, Value.PositionY + StrafeY, 0xFFFF0000, 6)
			end

			Value.PositionX = Value.PositionX + StrafeX * DeltaTime
			Value.PositionY = Value.PositionY + StrafeY * DeltaTime

			Value.DistanceFactor = (Value.PositionY - SnowCanvasPosnY + Value.SizeY) / (SnowCanvasSizeY + Value.SizeY / 2)

			if Value.DistanceFactor >= 1 then
				Value.PositionX = math.random(SnowCanvasPosnX + Value.SizeX, SnowCanvasPosnX + SnowCanvasSizeX) - Value.SizeX / 2
				Value.PositionY = SnowCanvasPosnY - Value.SizeY / 2
			end
		end
	end
end

function RenderSnowflakes()
	if DebugMode then
		dxDrawRectangle(SnowCanvasPosnX, SnowCanvasPosnY, SnowCanvasSizeX, SnowCanvasSizeY, tocolor(255, 255, 255, 50 * GameOpacity))
	end

	for I = 1, #SnowflakeParticles do
		local Value = SnowflakeParticles[I]

		if Value then
			local OpacityFactor = 0

			if Value.DistanceFactor < 0.1 then
				OpacityFactor = Value.DistanceFactor / 0.1
			elseif Value.DistanceFactor > 0.95 then
				OpacityFactor = 1 - (Value.DistanceFactor - 0.95) / (1 - 0.95)
			else
				OpacityFactor = 1
			end

			dxDrawImage(Value.PositionX - Value.SizeX / 2, Value.PositionY - Value.SizeY / 2, Value.SizeX, Value.SizeY, TextureElements[Value.TextureName], Value.RotationDeg, 0, 0, tocolor(255, 255, 255, 255 * Value.OpacityFactor * OpacityFactor * GameOpacity))
		end
	end
end

function RenderTheSanta()
	local DerivedColor = tocolor(255, 255, 255, 255 * GameOpacity)
	local ShadowOffset = 0

	-- Base Shadows
	dxDrawImage(SantaPosnX - ShadowOffset, SantaPosnY, SantaSizeX, SantaSizeY, TextureElements["Shadow_body"], -HeadRotation / 6, 0, 0, DerivedColor)
	dxDrawImage(SantaPosnX - ShadowOffset, SantaPosnY + ShadowOffset, SantaSizeX, SantaSizeY, TextureElements["Shadow_head"], HeadRotation, HeadRotationCenterX, HeadRotationCenterY, DerivedColor)

	-- Body
	dxDrawImage(SantaPosnX, SantaPosnY, SantaSizeX, SantaSizeY, TextureElements["Body"], -HeadRotation / 4, 0, 0, DerivedColor)

	-- Eyes
	local SantaCenterX = SantaPosnX + SantaSizeX / 2
	local SantaCenterY = SantaPosnY + SantaSizeY / 2

	if EyesState ~= "Sleep" then
		if FrameTime > EyesNextBlink then
			EyesState = "closed"
			EyesLastBlink = FrameTime
			EyesNextBlink = FrameTime + math.random(2500, 7500)
			EyesBlinkTwice = math.random() <= 0.4
		end

		local ElapsedTimeFromLastBlink = FrameTime - EyesLastBlink

		if EyesBlinkTwice then
			if ElapsedTimeFromLastBlink > 150 then
				EyesState = "Open"
			elseif ElapsedTimeFromLastBlink > 100 then
				EyesState = "closed"
			elseif ElapsedTimeFromLastBlink > 50 then
				EyesState = "Open"
			end
		elseif ElapsedTimeFromLastBlink > 50 then
			EyesState = "Open"
		end
	end

	if EyesState ~= "Open" then
		dxDrawImage(SantaPosnX, SantaPosnY, SantaSizeX, SantaSizeY, TextureElements["Eyeshut"], HeadRotation, HeadRotationCenterX, HeadRotationCenterY, DerivedColor)
	else
		local viewDirectionX = math.cos(EyesViewAngle)
		local viewDirectionY = math.sin(EyesViewAngle)

		dxDrawImage(SantaPosnX, SantaPosnY, SantaSizeX, SantaSizeY, TextureElements["Eyebg"], HeadRotation, HeadRotationCenterX, HeadRotationCenterY, DerivedColor)

		-- Left
		local LeftEyeX, LeftEyeY = RotatePoint(HeadRotation, SantaPosnX + Respc(239), SantaPosnY + Respc(121), SantaCenterX + HeadRotationCenterX, SantaCenterY + HeadRotationCenterY)

		if DebugMode then
			dxDrawCircle(LeftEyeX, LeftEyeY, EyeRadius, 0, 360)
		end

		LeftEyeX = LeftEyeX - EyeSizeX / 2 + viewDirectionX * (EyeRadius - EyeSpriteSizeX / 2)
		LeftEyeY = LeftEyeY - EyeSizeY / 2 + viewDirectionY * (EyeRadius - EyeSpriteSizeY / 2)

		dxDrawImage(LeftEyeX, LeftEyeY, EyeSizeX, EyeSizeY, TextureElements["Eye"], HeadRotation, 0, 0, DerivedColor)

		-- Right
		local RightEyeX, RightEyeY = RotatePoint(HeadRotation, SantaPosnX + Respc(268), SantaPosnY + Respc(109), SantaCenterX + HeadRotationCenterX, SantaCenterY + HeadRotationCenterY)

		if DebugMode then
			dxDrawCircle(RightEyeX, RightEyeY, EyeRadius, 0, 360)
		end

		RightEyeX = RightEyeX - EyeSizeX / 2 + viewDirectionX * (EyeRadius - EyeSpriteSizeX / 2)
		RightEyeY = RightEyeY - EyeSizeY / 2 + viewDirectionY * (EyeRadius - EyeSpriteSizeY / 2)

		dxDrawImage(RightEyeX, RightEyeY, EyeSizeX, EyeSizeY, TextureElements["Eye"], HeadRotation, 0, 0, DerivedColor)
	end

	-- Head
	if HeadInterpolation then
		if HeadInterpolation[2] then
			local ElapsedFraction = (FrameTime - HeadInterpolation[1]) / 1500

			HeadRotation = interpolateBetween(0, 0, 0, 6, 0, 0, ElapsedFraction, "InOutQuad")

			if ElapsedFraction >= 1 then
				HeadInterpolation[2] = false
				HeadInterpolation[1] = FrameTime
			end
		else
			local ElapsedFraction = (FrameTime - HeadInterpolation[1]) / 1500

			HeadRotation = interpolateBetween(6, 0, 0, 0, 0, 0, ElapsedFraction, "InOutQuad")

			if ElapsedFraction >= 1 then
				HeadInterpolation[2] = true
				HeadInterpolation[1] = FrameTime
			end
		end
	end

	dxDrawImage(SantaPosnX, SantaPosnY, SantaSizeX, SantaSizeY, TextureElements["Head2"], HeadRotation, HeadRotationCenterX, HeadRotationCenterY, DerivedColor)
	dxDrawImage(SantaPosnX, SantaPosnY, SantaSizeX, SantaSizeY, TextureElements["Head"], HeadRotation, HeadRotationCenterX, HeadRotationCenterY, DerivedColor)

	-- Glass
	dxDrawImage(SantaPosnX, SantaPosnY, SantaSizeX, SantaSizeY, TextureElements["Glass"], HeadRotation, HeadRotationCenterX, HeadRotationCenterY, DerivedColor)

	-- Mouth
	if SnoreTimer then
		if FrameTime > SnoreTimer then
			local ElapsedTime = FrameTime - SnoreTimer

			if ElapsedTime >= 3866 then
				SnoreState = false

				if EyesState == "Sleep" then
					SnoreTimer = FrameTime
					SnoreSound = playSound("Files/Sounds/Snore.mp3")
				end
			elseif ElapsedTime > 2408 then
				if EyesState == "Sleep" then
					if not SnoreState then
						table.insert(SymbolTable, {StartTime = FrameTime, TextureName = "Zzz"})
						SnoreState = true
					end
				end
			end
		end
	end

	if HohohoTimer then
		if FrameTime > HohohoTimer then
			local ElapsedTime = FrameTime - HohohoTimer

			if not HohohoSoundPlayed then
				playSound("Files/Sounds/Hohoho.mp3")
				HohohoSoundPlayed = true
			end

			if ElapsedTime > 1228 then
				if HohohoCount ~= 0 then
					HohohoTimer = FrameTime + math.random(9000, 15000)
					HohohoCount = 0
					HohohoSoundPlayed = false
					HohohoState = false
				end
			elseif ElapsedTime > 670 then
				if HohohoCount ~= 3 then
					HohohoCount = 3
					HohohoState = true
					table.insert(SymbolTable, {StartTime = FrameTime, TextureName = "Hoho"})
				end
			elseif ElapsedTime > 465 then
				HohohoState = false
			elseif ElapsedTime > 355 then
				if HohohoCount ~= 2 then
					HohohoCount = 2
					HohohoState = true
					table.insert(SymbolTable, {StartTime = FrameTime, TextureName = "Hoho"})
				end
			elseif ElapsedTime > 205 then
				HohohoState = false
			elseif ElapsedTime > 75 then
				if HohohoCount ~= 1 then
					HohohoCount = 1
					HohohoState = true
					table.insert(SymbolTable, {StartTime = FrameTime, TextureName = "Hoho"})
				end
			end
		end
	end

	local MouthRotatedX, MouthRotatedY = RotatePoint(HeadRotation, SnoreOriginX, SnoreOriginY, SantaCenterX + HeadRotationCenterX, SantaCenterY + HeadRotationCenterY)

	MouthRotatedX = MouthRotatedX - SymbolSizeX / 2
	MouthRotatedY = MouthRotatedY - SymbolSizeY / 2

	if not HohohoState then
		if SnoreState then
			dxDrawImage(SantaPosnX, SantaPosnY, SantaSizeX, SantaSizeY, TextureElements["Mouth2"], HeadRotation, HeadRotationCenterX, HeadRotationCenterY, DerivedColor)
		else
			dxDrawImage(SantaPosnX, SantaPosnY, SantaSizeX, SantaSizeY, TextureElements["Mouth"], HeadRotation, HeadRotationCenterX, HeadRotationCenterY, DerivedColor)
		end
	end

	for I = #SymbolTable, 1, -1 do
		local Value = SymbolTable[I]

		if Value then
			local ElapsedTime = FrameTime - Value.StartTime

			if ElapsedTime > 0 then
				local ElapsedFraction = ElapsedTime / 1750
				local OpacityFraction = 0

				if ElapsedTime > 1000 then
					OpacityFraction = 1 - (ElapsedTime - 1000) / 500

					if OpacityFraction < 0 then
						OpacityFraction = 0
					end
				else
					OpacityFraction = ElapsedTime / 500

					if OpacityFraction > 1 then
						OpacityFraction = 1
					end
				end

				local MovementAngle = math.pi - math.pi/3 * ElapsedFraction

				local SymbolPosnX = MouthRotatedX - ElapsedFraction * math.cos(MovementAngle) * Respc(250)
				local SymbolPosnY = MouthRotatedY - ElapsedFraction * math.sin(MovementAngle) * Respc(350)

				dxDrawImage(SymbolPosnX, SymbolPosnY, SymbolSizeX, SymbolSizeY, TextureElements[Value.TextureName], 0, 0, 0, tocolor(255, 255, 255, 255 * OpacityFraction * GameOpacity))

				if ElapsedFraction >= 1 then
					table.remove(SymbolTable, I)
				end
			end
		end
	end
end

function RenderMinigame()
	local DerivedAlpha = 255 * GameOpacity

	dxDrawImage(LogoPosnX, LogoPosnY, LogoSizeX, LogoSizeY, TextureElements["Bg"], 0, 0, 0, tocolor(255, 255, 255, DerivedAlpha))

	for I = CarouSelFirstVisibleItem, CarouselItemsNum + CarouSelFirstVisibleItem do
		local ItemId = CarouselItems[I]

		if ItemId then
			local RelativePosition = 1 - (I - 1) * CarouselItemSpacing

			if CarouselDistance > 0 then
				RelativePosition = RelativePosition + CarouselDistance * CarouselItemSpacing
			end

			local ScaleFactor = 1.0 - math.abs(0.5 - RelativePosition) * 2
			local AlphaFactor = 1.1 - math.abs(0.5 - RelativePosition) * 2 + 0.1

			if ScaleFactor < 0 then
				ScaleFactor = 0
			elseif ScaleFactor > 1 then
				ScaleFactor = 1
			end

			if AlphaFactor < 0 then
				AlphaFactor = 0
			elseif AlphaFactor > 1 then
				AlphaFactor = 1
			end

			if CarouSelFinishTimer then
				local ElapsedTime = FrameTime - CarouSelFinishTimer

				if CarouSelFocusItem ~= I then
					local TargetAlpha = AlphaFactor * 0.5

					if ElapsedTime < 500 then
						AlphaFactor = AlphaFactor - TargetAlpha * ElapsedTime / 500
					else
						AlphaFactor = TargetAlpha
					end
				else
					local targetScale = ScaleFactor * 1.4 --> 40x40

					if ElapsedTime < 500 then
						ScaleFactor = ScaleFactor + (targetScale - ScaleFactor) * ElapsedTime / 500
					else
						ScaleFactor = targetScale
					end
				end
			end

			local ItemSizeX = Respc(36) * ScaleFactor + Respc(26) * (1 - ScaleFactor)
			local ItemSizeY = Respc(36) * ScaleFactor + Respc(26) * (1 - ScaleFactor)

			local HoverSizeX = Respc(66) * ItemSizeX / Respc(36)
			local HoverSizeY = Respc(66) * ItemSizeY / Respc(36)

			local CenterPosnX = ItemsLinePosnX + ItemsLineSizeX * RelativePosition
			local CenterPosnY = ItemsLinePosnY + ItemsLineSizeY / 2

			local ItemPosnX = CenterPosnX - ItemSizeX / 2
			local ItemPosnY = CenterPosnY - ItemSizeY / 2

			dxDrawImage(ItemPosnX, ItemPosnY, ItemSizeX, ItemSizeY, ":cr_inventory/assets/items/" .. ItemId .. ".png", 0, 0, 0, tocolor(255, 255, 255, DerivedAlpha * AlphaFactor))

			if GoldItems[ItemId] then
				dxDrawImage(ItemPosnX + (ItemSizeX - HoverSizeX) / 2, ItemPosnY + (ItemSizeY - HoverSizeY) / 2, HoverSizeX, HoverSizeY, TextureElements["ItemHover"], 0, 0, 0, tocolor(GoldColor[1], GoldColor[2], GoldColor[3], DerivedAlpha * AlphaFactor))
			end

			local SensorMinX = ItemsLinePosnX + (ItemsLineSizeX - ItemSizeX) / 2 - ItemSizeX / 2
			local SensorMaxX = ItemsLinePosnX + (ItemsLineSizeX + ItemSizeX) / 2 + ItemSizeX / 2

			if DebugMode then
				dxDrawLine(SensorMinX, ItemsLinePosnY, SensorMinX, ItemsLinePosnY + ItemsLineSizeY, 0xFF00FF00, 1, true)
				dxDrawLine(SensorMaxX, ItemsLinePosnY, SensorMaxX, ItemsLinePosnY + ItemsLineSizeY, 0xFFFF0000, 1, true)
			end

			if CenterPosnX >= SensorMinX and CenterPosnX <= SensorMaxX then
				CarouselItemSensor = (CenterPosnX - SensorMinX) / (SensorMaxX - SensorMinX)

				if CarouSelFocusItem then
					if CarouSelFocusItem < I then
						CarouSelFocusItem = I
						playSound("Files/Sounds/Spin.mp3")
					end
				else
					CarouSelFocusItem = I
				end
			elseif CarouSelFocusItem == I then
				CarouselItemSensor = 0
			end

			if not CarouselTrackedItem then
				CarouselTrackedItem = CarouSelFocusItem
			end

			if CarouselTrackedItem == I then
				CarouselTrackedItemPosition = {ItemPosnX + ItemSizeX / 2, ItemPosnY + ItemSizeY / 2}
			end

			if RelativePosition >= 1.1 then
				CarouSelFirstVisibleItem = CarouSelFirstVisibleItem + 1

				CarouselItems[#CarouselItems + 1] = ChooseRandomItem()
				CarouselItems[I] = false

				if CarouselTrackedItem == I then
					CarouselTrackedItem = #CarouselItems
				end
			end
		end
	end

	local CarouselTextOpacity = 0

	if not CarouSelFinishTimer then
		if FrameTime > CarouselStartTimer - 500 then
			CarouselTextOpacity = (FrameTime - CarouselStartTimer + 500) / 500

			if CarouselTextOpacity > 1 then
				CarouselTextOpacity = 1
			end
		end
	else
		CarouselTextOpacity = 1
	end

	if CarouselTextOpacity > 0 then
		local WinOpacity = 0

		if CarouSelFinishTimer then
			local ElapsedTime = FrameTime - CarouSelFinishTimer

			if ElapsedTime < 500 then
				WinOpacity = ElapsedTime / 500
			else
				WinOpacity = 1
			end
		end

		dxDrawImage(
			ItemsLinePosnX + (ItemsLineSizeX - Respc(48)) / 2,
			ItemsLinePosnY,
			Respc(48),
			Respc(48),
			TextureElements["Ibg"],
			0, 0, 0,
			tocolor(255, 255, 255, 255 * (1 - WinOpacity) * CarouselTextOpacity * GameOpacity)
		)

		local ItemId = CarouselItems[CarouSelFocusItem]

		if ItemId then
			local ItemAlpha = 1 - math.abs(0.5 - CarouselItemSensor) * 2
			local ItemColor = {255, 255, 255}
			local FontScale = 0.5 * (1 - WinOpacity) + 0.625 * WinOpacity

			if GoldItems[ItemId] then
				ItemColor[1] = GoldColor[1]
				ItemColor[2] = GoldColor[2]
				ItemColor[3] = GoldColor[3]
			end

			-- Shine effect
			if WinOpacity > 0 then
				local ShineSizeX = Respc(400) * WinOpacity
				local ShineSizeY = Respc(400) * WinOpacity

				local ShinePosnX = ItemsLinePosnX + (ItemsLineSizeX - ShineSizeX) / 2
				local ShinePosnY = ItemsLinePosnY + (ItemsLineSizeY - ShineSizeY) / 2

				dxDrawImage(
					ShinePosnX,
					ShinePosnY,
					ShineSizeX,
					ShineSizeY,
					TextureElements["Win"],
					FrameTime / 50, 0, 0,
					tocolor(ItemColor[1], ItemColor[2], ItemColor[3], 255 * WinOpacity * GameOpacity)
				)
			end

			-- Item name shadow
			dxDrawText(
				exports.cr_inventory:getItemName(ItemId),
				ItemsLinePosnX + 1,
				ItemsLinePosnY + ItemsLineSizeY + 1,
				ItemsLinePosnX + ItemsLineSizeX + 1,
				1,
				tocolor(0, 0, 0, 200 * ItemAlpha * CarouselTextOpacity * GameOpacity),
				FontScale,
				GameMainFont,
				"center",
				"top"
			)

			-- Item name
			dxDrawText(
				exports.cr_inventory:getItemName(ItemId),
				ItemsLinePosnX,
				ItemsLinePosnY + ItemsLineSizeY,
				ItemsLinePosnX + ItemsLineSizeX,
				0,
				tocolor(ItemColor[1], ItemColor[2], ItemColor[3], 255 * ItemAlpha * CarouselTextOpacity * GameOpacity),
				FontScale,
				GameMainFont,
				"center",
				"top"
			)
		end
	end

	if CarouSelFinishTimer then
		local ElapsedTime = FrameTime - CarouSelFinishTimer

		if ElapsedTime > 11500 then
			if GameState ~= "FadeOut" then
				GameTimer = FrameTime
				GameState = "FadeOut"
			end
		elseif ElapsedTime > 0 then
			CarouselTrackedItem = CarouSelFocusItem

			if GameState ~= "GiveReward" then
				local ItemId = CarouselItems[CarouSelFocusItem]

				if ItemId then
					exports.cr_inventory:giveItem(localPlayer, ItemId, 1)

					if GoldItems[ItemId] then
						outputChatBox("#d75959[Láda]:#ffffff Nyereményed: #e8c55a" .. exports.cr_inventory:getItemName(ItemId), 255, 255, 255, true)
						exports['cr_infobox']:addBox("success", "Nyereményed: #e8c55a" .. exports.cr_inventory:getItemName(ItemId))
					else
						outputChatBox("#d75959[Láda]:#ffffff Nyereményed: #ACD373" .. exports.cr_inventory:getItemName(ItemId), 255, 255, 255, true)
						exports['cr_infobox']:addBox("success", "Nyereményed: #e8c55a" .. exports.cr_inventory:getItemName(ItemId))
					end
				end

				GameState = "GiveReward"
			end

			local FadeFactor = ElapsedTime / 650

			if FadeFactor < 1 then
				if isElement(BgPreMusic) then
					setSoundVolume(BgPreMusic, 1 - FadeFactor)
				end

				if isElement(BgWinMusic) then
					setSoundVolume(BgWinMusic, FadeFactor)
				end
			else
				if isElement(BgPreMusic) then
					if not isSoundPaused(BgPreMusic) then
						setSoundPaused(BgPreMusic, true)
					end
				end

				if isElement(BgWinMusic) then
					setSoundVolume(BgWinMusic, 1)
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------

function RotatePoint(Angle, PointX, PointY, CenterX, CenterY)
	Angle = math.rad(Angle)

	local cosAngle = math.cos(Angle)
	local sinAngle = math.sin(Angle)

	-- translate point back to origin
	PointX = PointX - CenterX
	PointY = PointY - CenterY

	-- rotate point
	local rotatedX = PointX * cosAngle - PointY * sinAngle
	local rotatedY = PointX * sinAngle + PointY * cosAngle

	-- translate point back
	PointX = rotatedX + CenterX
	PointY = rotatedY + CenterY

	return PointX, PointY
end

local function GetBezierValue(t, a, b)
	return (((1 - 3 * b + 3 * a) * t + (3 * b - 6 * a)) * t + (3 * a)) * t
end

local function GetBezierSlope(t, a, b)
	return 3 * (1 - 3 * b + 3 * a) * t * t + 2 * (3 * b - 6 * a) * t + (3 * a)
end

function CreateBezierEasing(X1, Y1, X2, Y2)
	local NewtonIterations = 4
	local NewtonMinimumSlope = 0.001

	local SubdivisionPrecision = 0.0000001
	local SubdivisionMaxIterations = 11

	local SampleTableSize = 11
	local SampleStepSize = 1 / (SampleTableSize - 1)

	local SampleValues = {}

	if X1 ~= Y1 or X2 ~= Y2 then
		for i = 1, SampleTableSize do
			SampleValues[i] = GetBezierValue(SampleStepSize * (i - 1), X1, X2)
		end
	end

	local function FindNewFractionOfTime(TimeFraction)
		local IntervalStart = 0
		local CurrentSample = 1

		while CurrentSample ~= SampleTableSize and SampleValues[CurrentSample] <= TimeFraction do
			IntervalStart = IntervalStart + SampleStepSize
			CurrentSample = CurrentSample + 1
		end

		CurrentSample = CurrentSample - 1

		local CurrSampleValue = SampleValues[CurrentSample]
		local NextSampleValue = SampleValues[CurrentSample + 1]

		local DistanceFactor = (TimeFraction - CurrSampleValue) / (NextSampleValue - CurrSampleValue)
		local GuessForTime = IntervalStart + DistanceFactor * SampleStepSize
		local InitialSlope = GetBezierSlope(GuessForTime, X1, X2)

		if InitialSlope == 0 then
			return GuessForTime
		-- Newton Raphson Iteration
		elseif InitialSlope >= NewtonMinimumSlope then
			for I = 1, NewtonIterations do
				local CurrentSlope = GetBezierSlope(GuessForTime, X1, X2)

				if CurrentSlope == 0 then
					return GuessForTime
				end

				local CurrentTime = GetBezierValue(GuessForTime, X1, X2) - TimeFraction

				if CurrentTime ~= 0 then
					GuessForTime = GuessForTime - CurrentTime / CurrentSlope
				end
			end
			return GuessForTime
		-- Binary Subdivide
		else
			local IntervalEnd = IntervalStart + SampleStepSize
			local CurrentValue = 0
			local CurrentTime = 0
			local IteratorIndex = 1

			while math.abs(CurrentValue) > SubdivisionPrecision and IteratorIndex < SubdivisionMaxIterations do
				IteratorIndex = IteratorIndex + 1

				CurrentTime = IntervalStart + (IntervalEnd - IntervalStart) * 0.5
				CurrentValue = GetBezierValue(CurrentTime, X1, X2) - TimeFraction

				if CurrentValue > 0 then
					IntervalEnd = CurrentTime
				else
					IntervalStart = CurrentTime
				end
			end

			return CurrentTime
		end
	end

	return function (TimeFraction)
		if X1 == Y1 and X2 == Y2 then
			return TimeFraction
		end

		if TimeFraction == 0 then
			return 0
		elseif TimeFraction == 1 then
			return 1
		end

		return GetBezierValue(FindNewFractionOfTime(TimeFraction), Y1, Y2)
	end
end
