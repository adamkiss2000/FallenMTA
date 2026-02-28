setTimer(function()
    if not MySQL.isConnected() then
        MySQL.connect()
    end
end, 15000, 0)

setTimer(function()
    if MySQL.isConnected() then
        MySQL.exec("SELECT 1")
    end
end, 30000, 0)