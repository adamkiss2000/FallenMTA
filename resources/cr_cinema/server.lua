local cinemaStart = 0
local currentVodId = false
local currentMovieIndex = false
local lastCinemaSync = {}

local availableMovies = {
    {
        name = "Kincs, ami nincs",
        vodId = "L4iUmQS0uXI"
    },

    {
        name = "Made in Hungária",
        vodId = "4uyYFInms8g"
    },

    {
        name = "Bűnvadászok",
        vodId = "6sdzCv0MAas"
    },

    {
        name = "És megint dühbe jövünk",
        vodId = "SgAlcqrHD7Q"
    },

    {
        name = "Londoni csapás",
        vodId = "ViMjn4j4NKQ"
    },

    {
        name = "Jexi - A Túl okostelefon",
        vodId = "r-8gn0RxSV0"
    },

    {
        name = "Pixel",
        vodId = "nAPCIJyvsn4"
    },

    {
        name = "Forráskód",
        vodId = "AXNn9nDPK1s"
    },

    {
        name = "Üvegtigris",
        vodId = "kGuaDIcVG6Y"
    },

    {
        name = "Üvegtigris 2",
        vodId = "1pE6LSy33Dg"
    },

    {
        name = "Üvegtigris 3",
        vodId = "kvW-2S3qWYo"
    },

    {
        name = "Argo",
        vodId = "5ZHDrcrQEIc"
    },

    {
        name = "Pappa Pia",
        vodId = "uWH1pCfoYTA"
    },

    {
        name = "Zimmer Feri",
        vodId = "p3IQle8yFvs"
    },

    {
        name = "Vigyázat vadnyugat",
        vodId = "7CC5cyMqteI"
    },

    {
        name = "Need for Speed",
        vodId = "08YHoKX25sE"
    },

    {
        name = "Taxi 1",
        vodId = "BNpPBoZQ2iY"
    },

    {
        name = "Az éjszakai járőr",
        vodId = "UQfTvjLvw1g"
    }
}

function startMovie(thePlayer, vodId)
    local players = getElementsByType("player")

    cinemaStart = getTickCount()
    currentVodId = vodId

    triggerClientEvent(players, "cinema.onCinemaStart", thePlayer, vodId, 0, currentMovieIndex)
end

function stopMovie(thePlayer)
    local players = getElementsByType("player")

    cinemaStart = 0
    currentVodId = false
    currentMovieIndex = false

    triggerClientEvent(players, "cinema.onCinemaStop", thePlayer)
end

function startCinemaCommand(thePlayer, cmd, vodId)
    if exports.cr_permission:hasPermission(thePlayer, cmd) then 
        if not vodId then 
            local syntax = exports.cr_core:getServerSyntax(false, "lightyellow")
            outputChatBox(syntax .. "/" .. cmd .. " [videó id a ?v= után]", thePlayer, 255, 0, 0, true)
            return
        end

        vodId = tostring(vodId)

        -- Állítsuk be a megfelelő indexet
        for i, v in ipairs(availableMovies) do
            if v.vodId == vodId then
                currentMovieIndex = i
                break
            end
        end

        startMovie(thePlayer, vodId)
    end
end
addCommandHandler("startcinema", startCinemaCommand, false, false)

function syncCinemaCommand(thePlayer)
    if thePlayer:getData("loggedIn") then 
        if currentVodId then 
            if not lastCinemaSync[thePlayer] then 
                lastCinemaSync[thePlayer] = 0
            end

            if getTickCount() - lastCinemaSync[thePlayer] >= 10000 then 
                syncCinema(thePlayer)

                lastCinemaSync[thePlayer] = getTickCount()
            end
        end
    end
end
addCommandHandler("synccinema", syncCinemaCommand, false, false)

function onJoin()
    syncCinema(source)
end
addEventHandler("onPlayerJoin", root, onJoin)

function onQuit()
    lastCinemaSync[source] = nil
end
addEventHandler("onPlayerQuit", root, onQuit)

function syncCinema(p)
    local thePlayer = client or p

    if isElement(thePlayer) and currentVodId then 
        triggerClientEvent(thePlayer, "cinema.onCinemaStart", thePlayer, currentVodId, getTickCount() - cinemaStart, currentMovieIndex)
    end
end
addEvent("cinema.sync", true)
addEventHandler("cinema.sync", root, syncCinema)

function startMovieHandler(vodId, hoverMovieIndex)
    if isElement(client) then 
        currentMovieIndex = hoverMovieIndex

        startMovie(client, vodId)
    end
end
addEvent("cinema.startMovie", true)
addEventHandler("cinema.startMovie", root, startMovieHandler)

function stopMovieHandler()
    if isElement(client) then 
        stopMovie(client)
    end
end
addEvent("cinema.stopMovie", true)
addEventHandler("cinema.stopMovie", root, stopMovieHandler)

addEventHandler("onPlayerLogin", root,
    function()
        syncCinema(source)
    end
)