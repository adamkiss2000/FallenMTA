Core.Events = {}

function Core.Events.register(name, remote)
    addEvent(name, remote or false)
end

function Core.Events.call(name, ...)
    triggerEvent(name, root, ...)
end