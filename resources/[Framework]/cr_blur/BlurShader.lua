
local screenWidth, screenHeight = guiGetScreenSize()
local blurShaders = {}
local indexByName = {}
local myScreenSource = dxCreateScreenSource(screenWidth, screenHeight)
local isRenderingShader = false

function createBlur(name, strenght, extra)
    if indexByName[name] then
        removeBlur(name)
    end

    local x,y,w,h
    if extra and type(extra) == "table" and #extra >= 1 then
        x,y,w,h = unpack(extra)
        table.insert(blurShaders, {
            s_name = name,
            shader = dxCreateShader("shaders/BlurShader.fx"),
            strenght_s = strenght,
            x = x, y = y, w = w, h = h
        })
    else
        table.insert(blurShaders, {
            s_name = name,
            shader = dxCreateShader("shaders/BlurShader.fx"),
            strenght_s = strenght
        })
    end

    indexByName[name] = #blurShaders

    if #blurShaders >= 1 and not isRenderingShader then
        isRenderingShader = true
        exports.cr_render:createRender("cr_blur_render", renderBlur)
    end
end

function updateBlurPosition(name, pos)
    if indexByName[name] then
        local k = indexByName[name]
        local x,y,w,h = unpack(pos)
        blurShaders[k].x = x
        blurShaders[k].y = y
        blurShaders[k].w = w
        blurShaders[k].h = h
    end
end

function updateBlurStrength(name, num)
    if indexByName[name] then
        local k = indexByName[name]
        blurShaders[k].strenght_s = num
    end
end

function removeBlur(name)
    for k, v in ipairs(blurShaders) do
        if v.s_name == name then
            if isElement(v.shader) then
                destroyElement(v.shader)
            end

            table.remove(blurShaders, k)
            indexByName[name] = nil
            collectgarbage("collect")

            if #blurShaders <= 0 and isRenderingShader then
                isRenderingShader = false
                exports.cr_render:destroyRender("cr_blur_render")
            end
            return
        end
    end
end

function renderBlur()
    if #blurShaders == 0 then return end

    dxUpdateScreenSource(myScreenSource)

    for _, v in ipairs(blurShaders) do
        if v.shader then
            dxSetShaderValue(v.shader, "ScreenSource", myScreenSource)
            dxSetShaderValue(v.shader, "BlurStrength", v.strenght_s)
            dxSetShaderValue(v.shader, "UVSize", screenWidth, screenHeight)

            local x = v.x or 0
            local y = v.y or 0
            local w = v.w or screenWidth
            local h = v.h or screenHeight

            dxDrawImageSection(x, y, w, h, x, y, w, h, v.shader)
        end
    end
end
