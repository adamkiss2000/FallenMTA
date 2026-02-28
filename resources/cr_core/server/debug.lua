function Core.Debug(message, level)
    if not Core.Config.debug then return end
    outputDebugString("[CORE] " .. tostring(message), level or 3)
end