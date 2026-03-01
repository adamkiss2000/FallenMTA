local renderList = {}
local isRendering = false

-- ==========================
-- INTERNAL RENDER LOOP
-- ==========================

local function mainRender()
    for _, data in pairs(renderList) do
        if type(data.func) == "function" then
            data.func()
        end
    end
end

-- ==========================
-- CREATE RENDER
-- ==========================

function createRender(name, func)
    if not name or type(func) ~= "function" then
        outputDebugString("[cr_render] Invalid createRender call.")
        return false
    end

    if renderList[name] then
        return false -- már létezik
    end

    renderList[name] = {
        func = func
    }

    if not isRendering then
        isRendering = true
        addEventHandler("onClientRender", root, mainRender)
    end

    return true
end

-- ==========================
-- DESTROY RENDER
-- ==========================

function destroyRender(name)
    if not renderList[name] then
        return false
    end

    renderList[name] = nil

    if next(renderList) == nil and isRendering then
        removeEventHandler("onClientRender", root, mainRender)
        isRendering = false
    end

    return true
end

-- ==========================
-- CHECK IF ACTIVE
-- ==========================

function isRenderActive(name)
    return renderList[name] ~= nil
end

-- ==========================
-- CLEANUP ON STOP
-- ==========================

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if isRendering then
            removeEventHandler("onClientRender", root, mainRender)
        end
        renderList = {}
        isRendering = false
    end
)