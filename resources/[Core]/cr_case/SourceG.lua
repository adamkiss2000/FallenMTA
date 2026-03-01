DebugMode = false

WeightedItems = {
    -- Minel nagyobb annal nagyobb ra az esely

    --skines fegok
    [72] = 25,
    [139] = 25,
    [140] = 25,
    [141] = 25,
    [143] = 25,
    [155] = 25,
    [156] = 25,
    [199] = 25,
    [171] = 25,
    [73] = 25,
    [49] = 25,
    [55] = 25,
    [51] = 25,
    [59] = 25,
    [61] = 25,
    [57] = 25,
    [64] = 35,


    --antik meg minden ilyen fos
    [196] = 50,
    [197] = 50,
    [198] = 50,
    [321] = 50,
    [144] = 50,
    [157] = 50,
    [106] = 50,

    -- innentol a simak
    [5] = 300,
    [6] = 300,
    [7] = 300,
    [8] = 200,

}

GoldColor = {244, 205, 70}

GoldItems = {
    [72] = true,
    [139] = true,
    [140] = true,
    [141] = true,
    [143] = true,
    [155] = true,
    [156] = true,
    [49] = true,
    [55] = true,
    [321] = true,
    [51] = true,
    [59] = true,
    [61] = true,
    [57] = true,
    [64] = true,

}

function ChooseRandomItem()
	local weightSum = 0

	for itemId, itemWeight in pairs(WeightedItems) do
		weightSum = weightSum + itemWeight
	end

	local selectedWeight = math.random(weightSum)
	local iteratedWeight = 0

	for itemId, itemWeight in pairs(WeightedItems) do
		iteratedWeight = iteratedWeight + itemWeight

		if selectedWeight <= iteratedWeight then
			return itemId
		end
	end

	return false
end
