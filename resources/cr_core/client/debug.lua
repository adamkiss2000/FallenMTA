function Core.DebugClient(message)
    if not Core.Config.debug then return end
    outputDebugString("[CORE-CLIENT] " .. tostring(message))
end