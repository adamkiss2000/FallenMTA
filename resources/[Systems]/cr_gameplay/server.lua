function setGhostMode(element, state, alpha, settings)
    if not isElement(element) then return false end

    triggerClientEvent(root, "cr_gameplay:ghostMode", element, element, state, alpha, settings or {})
    return true
end