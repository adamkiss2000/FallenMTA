worldX, worldY = -25.6328125, -364.9140625 -- # DO NOT TOUCH IT!
farmInteriorPosition = {-23.140625, -367.431640625, 5.4296875} -- # DO NOT TOUCH IT!

-- NOTE: zCorrection: sets the start position of the plant on the Z-Axis
-- NOTE: growZ: sets the growing position on the Z-Axis
-- NOTE: If growZ is not set, the plant only grows by scale
seedTable = {
	{name = "Marihuána", modelID = 859, seedImage = "seed", seedID = 198, itemID = 184, zCorrection = 0},
	{name = "Sárgarépa", modelID = 16192, seedImage = "seed", seedID = 329, itemID = 326, zCorrection = 0},
	{name = "Retek", modelID = 16193, seedImage = "seed", seedID = 330, itemID = 325, zCorrection = 0},
	{name = "Petrezselyem", modelID = 16675, seedImage = "seed", seedID = 328, itemID = 327, zCorrection = 0.1},
	{name = "Saláta", modelID = 16676, seedImage = "seed", seedID = 331, itemID = 324, zCorrection = 0},
	{name = "Vöröshagyma", modelID = 16134, seedImage = "seed", seedID = 332, itemID = 323, zCorrection = 0, growZ = 0.26},
}

-- NOTE: Seed index corresponds to the index of the plant in the seedTable
seedSellTable = {
	{
		skinID = 73,
		position = {244.30442810059, 84.14094543457, 3.7001614570618, 117.48614501953},
		seedIndex = 2,
	},
	{
		skinID = 15,
		position = {238.33018493652, 89.988922119141, 3.6209754943848, 145.30056762695},
		seedIndex = 3,
	},
	{
		skinID = 31,
		position = {229.19979858398, 90.206825256348, 3.8222417831421, 210.16116333008},
		seedIndex = 4,
	},
	{
		skinID = 161,
		position = {222.70953369141, 85.434288024902, 3.890625, 250},
		seedIndex = 5,
	},
	{
		skinID = 162,
		position = {221.99844360352, 84.309532165527, 3.890625, 250},
		seedIndex = 6,
	},
}

permissionMenu = {"Kapálás", "Ásás", "Locsolás", "Ültetés", "Növény betakarítás", "Farm nyitás/zárás"}

-- # Marker Colors RGBA
farmMarkerColor = {197, 172, 119, 100}
farmRentMarkerColor = {124, 197, 118, 100}

-- # Tools
numberOfSpadesAllowedInFarm = 2 -- # Sets how many spades can be taken in the farm
numberOfHoesAllowedInFarm = 2 -- # Sets how many hoes can be taken in the farm

-- # Element Datas
characterIDElementData = "char >> id"
moneyElementData = "char >> money"
premiumElementData = "char >> premiumPoints"
playerNameElementData = "char >> name"

-- # Renting
rentPrice = 12500
rentPricePremium = 200
defaultRentTime = 60000*60*24*7 -- # The renting time / in milliseconds /

-- # Times
healthTime = 1000*60*60 -- # The time until the plant's health goes to 0 / in milliseconds /
growingTime = 1000*60*35 -- # The time until the plant is growing / in milliseconds /
waterLosingTime = 3600000*20 -- # The time until the water level goes back to 0 / in milliseconds /
cultivateTime = 1000 -- # The time of the cultivating animation  / in milliseconds /
diggingTime = 4500 -- # The time of the digging animation  / in milliseconds /
plantingTime = 3000 -- # The time of the planting animation  / in milliseconds /
harvestTime = 10000 -- # The time of the harvesting animation  / in milliseconds /
wateringTime = 10000 -- # The time of the watering animation  / in milliseconds /



-- # Languages
selectedLanguage = "hu" -- NOTE: available languades: en - english; de - german; hu - hungarian
farmPrefix = "#7cc576[CountrySide - Farm]: #ffffff"


translationTable = {
	["hu"] = {
		["harvest_button"] = "Növény aratása",
		["wateringLevel"] = "Nedvesség",
		["changeFarmName_button"] = "Módosítás",
		["editFarmName_button"] = "Szerkesztés",
		["farmManagementTitle"] = "Farm tábla:",
		["permission_button"] = "Jogosultságok",
		["permission_addNewMember"] = "Új tag hozzáadása",
		["permission_save"] = "Mentés",
		["permission_add"] = "Hozzáad",
		["permission_noPlayerFound"] = "Játékos nem található",
		["permission_morePlayerFound"] = " ilyen nevű játékos találva.",
		["permission_selfAdding"] = " Magadat nem tudod hozzáadni.",
		["tools_hoe"] = "Kapa",
		["tools_shovel"] = "Ásó",
		["tools_wateringCan"] = "Kanna",
		["ground_wateringLevel"] = "Nedvesség:",
		["ground_state"] = "Állapot:",
		["ground_uncultivated"] = "Műveletlen",
		["ground_cultivating"] = "művelés alatt",
		["ground_cultivated"] = "Megkapálva",
		["ground_planting"] = "művelés alatt",
		["ground_digging"] = "művelés alatt",
		["ground_readyForPlanting"] = "Ültetésre kész",
		["ground_growing"] = "Növekedés:",
		["ground_fillTheHole"] = "Lyuk betömése",
		["ground_plantTheSeed"] = "Növény ültetése",
		["ground_seedMenu"] = "Vetőmagok",
		["chatbox_hoeDown"] = "Előbb tedd le a kapát!",
		["chatbox_shovelDown"] = "Előbb tedd le az ásót!",
		["chatbox_toolDown"] = "Előbb tedd le az eszközt, ami a kezedben van!",
		["chatbox_tryHarvest"] = "Még nem fejlődött ki eléggé a növény.",
		["chatbox_alreadyCultivated"] = "Már teljesen meg van kapálva.",
		["chatbox_canNotCultivate"] = "Ameddig be van ültetve a föld, addig nem kapálhatod.",
		["chatbox_notEnoughCultivation"] = "Nincs eléggé megkapálva a föld.",
		["chatbox_rentFarmCommand1"] = "Bérléshez használd a '#7cc576/rentfarm' #ffffffparancsot.",
		["chatbox_rentFarmCommand2"] = "Heti bérleti díj: #7cc576$"..rentPrice,
		["chatbox_farmLocked"] = "Ez a farm zárva van",
		["chatbox_openFarmDoor"] = "Kinyitottad a farm ajtaját.",
		["chatbox_closeFarmDoor"] = "Bezártad a farm ajtaját.",
		["chatbox_notEnoughPP"] = "Nincs elég Prémium Pontod.",
		["chatbox_notEnoughMoney"] = "Nincs elég pénzed.",
		["chatbox_alreadyOwned"] = "Ezt a farmot már valaki bérli.",
		["chatbox_rentSuccess"] = "Sikeresen kibérelted a farmot.",
		["chatbox_canNotReach"] = "Nem éred el ezt a blokkot.",
		["chatbox_noSeed"] = "Nincs nálad ilyen termés ebben a mennyiségben.",
		["chatbox_plantSold"] = "Sikeresen eladtad a kiválasztott növényt.",
		["chatbox_minigame_amount"] = "Mennyiség:",
		["chatbox_minigame_price"] = "Darabár:",
		["chatbox_minigame_total"] = "Összesen:",
		["chatbox_minigame_description"] = "Tartsd lenyomva a ‘#99cc99Space#ffffff’ billentyűt, \nameddig a nyíl el nem éri a zöld mezőt.",
		["minigameTitle"] = "Eladás - ",
		["board_forRentText"] = "KIADÓ!",
		["board_enterInterior"] = "Nyomj 'E' billentyűt a belépéshez.",
		["piecesShortly"] = "db",
	},
}


function getTranslatedText(index)
	if translationTable[selectedLanguage] then
		if translationTable[selectedLanguage][index] then
			return translationTable[selectedLanguage][index]
		else
			return "No matching text"
		end
	else
		return "This language is not supported."
	end
end

function hasPlayerItem(player, itemID)
 	return exports.cr_inventory:hasItem(player, itemID) 
end

function getItemCount(player,itemID)
	local haveItem = exports.cr_inventory:hasItem(player,itemID)
	sum = 0
	if haveItem then
		local playerItems = exports.cr_inventory:getItems(player, 1)

        for k, v in pairs(playerItems) do 
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)

            if itemid == itemID then 
                sum = sum +1
            end
        end
	end
	return sum
end

function takeSeedFromPlayer(player,itemID)
	local haveItem = exports.cr_inventory:hasItem(player,itemID)

	if haveItem then
		local playerItems = exports.cr_inventory:getItems(player, 1)

        for k, v in pairs(playerItems) do 
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)

            if itemid == itemID then 
                exports.cr_inventory:deleteItem(player, k, itemID)
                break
            end
        end
	end
end

local dataTable = {}

function takePlantFromPlayer(player,itemID, itemCount)
	local haveItem = exports.cr_inventory:hasItem(player,itemID)

	if haveItem then
		local playerItems = exports.cr_inventory:getItems(player, 1)

        for k, v in pairs(playerItems) do 
            local id, itemid, value, count, status, dutyitem, premium, nbt = unpack(v)

            if itemid == itemID then 
                exports.cr_inventory:deleteItem(player, k, itemID)
                break
            end
        end
	end
end

function givePlayerHarvestedPlant(player,itemID, health)
	if health > 10 then
		exports.cr_inventory:giveItem(player,itemID, 1)
	end
end
