MySQL.Connection = nil
MySQL.State = {
    connected = false,
    connecting = false
}

function MySQL.connect()
    if MySQL.State.connecting then return end
    MySQL.State.connecting = true

    MySQL.Connection = dbConnect(
        "mysql",
        "dbname=" .. MySQL.Config.database ..
        ";host=" .. MySQL.Config.host ..
        ";charset=" .. MySQL.Config.charset,
        MySQL.Config.username,
        MySQL.Config.password,
        "tag=cr_mysql;multi_statements=1"
    )

    if MySQL.Connection then
        MySQL.State.connected = true
        MySQL.State.connecting = false
        outputDebugString("[MySQL] Connected successfully.")
        dbExec(MySQL.Connection, "SET NAMES utf8")
    else
        MySQL.State.connected = false
        MySQL.State.connecting = false
        outputDebugString("[MySQL] Connection failed. Retrying...", 1)
        setTimer(MySQL.connect, MySQL.Config.reconnectInterval, 1)
    end
end

function MySQL.isConnected()
    return MySQL.State.connected
end