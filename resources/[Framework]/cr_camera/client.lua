local camData = {
    active = false,
    object1 = nil,
    object2 = nil,
    timer1 = nil,
    timer2 = nil,
    timer3 = nil
}

-- ==========================
-- INTERNAL RENDER
-- ==========================

local function camRender()
    if not camData.object1 or not camData.object2 then return end

    if not isElement(camData.object1) or not isElement(camData.object2) then
        stopSmoothMoveCamera()
        return
    end

    local x1, y1, z1 = getElementPosition(camData.object1)
    local x2, y2, z2 = getElementPosition(camData.object2)

    setCameraMatrix(x1, y1, z1, x2, y2, z2)
end

-- ==========================
-- STOP CAMERA
-- ==========================

function stopSmoothMoveCamera()
    if not camData.active then return false end

    if isTimer(camData.timer1) then killTimer(camData.timer1) end
    if isTimer(camData.timer2) then killTimer(camData.timer2) end
    if isTimer(camData.timer3) then killTimer(camData.timer3) end

    if isElement(camData.object1) then destroyElement(camData.object1) end
    if isElement(camData.object2) then destroyElement(camData.object2) end

    exports.cr_render:destroyRender("cr_camera_render")

    camData = {
        active = false,
        object1 = nil,
        object2 = nil,
        timer1 = nil,
        timer2 = nil,
        timer3 = nil
    }

    return true
end

-- ==========================
-- START SMOOTH CAMERA
-- ==========================

function smoothMoveCamera(
    x1, y1, z1,
    x1t, y1t, z1t,
    x2, y2, z2,
    x2t, y2t, z2t,
    time,
    easing
)

    if camData.active then
        stopSmoothMoveCamera()
    end

    easing = easing or "InOutQuad"

    camData.object1 = createObject(1337, x1, y1, z1)
    camData.object2 = createObject(1337, x1t, y1t, z1t)

    if not camData.object1 or not camData.object2 then
        return false
    end

    setElementAlpha(camData.object1, 0)
    setElementAlpha(camData.object2, 0)

    setElementCollisionsEnabled(camData.object1, false)
    setElementCollisionsEnabled(camData.object2, false)

    setObjectScale(camData.object1, 0.01)
    setObjectScale(camData.object2, 0.01)

    moveObject(camData.object1, time, x2, y2, z2, 0, 0, 0, easing)
    moveObject(camData.object2, time, x2t, y2t, z2t, 0, 0, 0, easing)

    exports.cr_render:createRender("cr_camera_render", camRender)

    camData.timer1 = setTimer(stopSmoothMoveCamera, time, 1)
    camData.timer2 = setTimer(destroyElement, time, 1, camData.object1)
    camData.timer3 = setTimer(destroyElement, time, 1, camData.object2)

    camData.active = true

    return true
end

-- ==========================
-- CHECK STATE
-- ==========================

function isCameraMoving()
    return camData.active
end

-- ==========================
-- CLEANUP
-- ==========================

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        stopSmoothMoveCamera()
    end
)