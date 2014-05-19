
local xshift = 0
local yshift = 0

local scaleValues = { 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2, 1.4, 1.6, 1.8, 2 }
local scale = 6

local cameraShiftValue = 50

local function rotatePoint(x, y, angle)
    local nx = math.cos(angle) * x - math.sin(angle) * y
    local ny = math.sin(angle) * x + math.cos(angle) * y
    return nx, ny
end

cameraHandler = {}

function cameraHandler.init()

end

function cameraHandler.getShifts()
    return xshift, yshift
end

function cameraHandler.getZoom()
    return scaleValues[scale]
end

function cameraHandler.zoomIn()
    if scale < #scaleValues then scale = scale + 1 end
end

function cameraHandler.zoomOut()
    if scale > 1 then scale = scale - 1 end
end

function cameraHandler.shiftCamera(xv, yv)
    if xv then xshift = xshift - (cameraShiftValue / scaleValues[scale]) * xv end
    if yv then yshift = yshift - (cameraShiftValue / scaleValues[scale]) * yv end
end

-- returns world coordinates
function cameraHandler.convertScreenCoordinates(x, y)
    local xt, yt = rotatePoint(x - love.graphics.getWidth() / 2, y - love.graphics.getHeight() / 2, -math.pi / 4)
    local xt2 = (xt / scaleValues[scale] - xshift)
    local yt2 = (yt / scaleValues[scale] - yshift)
    local xt3 = xt2--(xt2 - yt2 * sheark) / (1 - sheark * sheark)
    local yt3 = yt2--(yt2 - xt2 * sheark) / (1 - sheark * sheark)
    return xt3 / tilesize + 1, yt3 / tilesize + 1
end

function cameraHandler.convertWorldCoordinates(x, y)
    local xt, yt = rotatePoint(x + love.graphics.getWidth() / 2, y + love.graphics.getHeight() / 2, math.pi / 4)
    local xt2 = (xt * scaleValues[scale] + xshift)
    local yt2 = (yt * scaleValues[scale] + yshift)
    local xt3 = xt2--(xt2 + yt2 * sheark)
    local yt3 = yt2--(yt2 + xt2 * sheark)
    return xt3 * tilesize - 1, yt3 * tilesize - 1
end