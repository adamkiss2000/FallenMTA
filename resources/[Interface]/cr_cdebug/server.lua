addEventHandler("onDebugMessage",root,function(message,level,file,line)
    for _, player in ipairs(getElementsByType("player")) do
        triggerClientEvent(player, "debug.sendClient", player, level, line, message, "server")
    end
end);