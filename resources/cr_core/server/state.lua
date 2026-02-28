Core.State = {
    serverReady = false,
    startTick = getTickCount()
}

function Core.isServerReady()
    return Core.State.serverReady
end