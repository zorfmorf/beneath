
gameInputHandler = {}

local MOUSE_CLICK_TIMEOUT = 0.2

local mousePressedTime = 0
local mouseLeftPressed = false
local lastMousePos = { x=0, y=0 }
local mouseShiftActive = false

function gameInputHandler.update(dt)
    
    if mouseShiftActive then
        local x, y = love.mouse.getPosition()
        local dx = x - lastMousePos.x
        local dy = y - lastMousePos.y
        cameraHandler.dragShiftCamera(dx, dy)
        lastMousePos.x = x
        lastMousePos.y = y
    end
    
    if mouseLeftPressed then
        mousePressedTime = mousePressedTime + dt
    end
end


function gameInputHandler.keypressed(key, isRepeat)
    if key == "up" and not isRepeat then cameraHandler.layerUp() end
    if key == "down" and not isRepeat then cameraHandler.layerDown() end
    if key == "escape" then displayMenu = not displayMenu end
    if key == "f1" then console = not console end
end


function gameInputHandler.keyreleased(key, isRepeat)
    
end


function gameInputHandler.mousereleased(x, y, button)
    if button == "l" then
        mouseLeftPressed = false
        mouseShiftActive = false
        
        if mousePressedTime < MOUSE_CLICK_TIMEOUT then
            if not hudHandler.catchMouseClick(x, y) then
                local xc, yc = cameraHandler.convertScreenCoordinates(x, y)
                logicHandler.tileClick(xc, yc)
            end
        end
        
    end
end


function gameInputHandler.mousepressed(x, y, button)
    if button == "l" then
        
        mouseLeftPressed = true
        mousePressedTime = 0
        
        mouseShiftActive = true
        local x, y = love.mouse.getPosition()
        lastMousePos.x = x
        lastMousePos.y = y
        
    end
    
    if button == "r" then
        logicHandler.deselect()
    end
    
    if button == "wu" then cameraHandler.zoomIn() end
    if button == "wd" then cameraHandler.zoomOut() end
end
