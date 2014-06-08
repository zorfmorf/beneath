
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
    if key == "up" and not isRepeat then cameraHandler.keyShiftCamera(0, -1) end
    if key == "down" and not isRepeat then cameraHandler.keyShiftCamera(0, 1) end
    if key == "left" and not isRepeat then cameraHandler.keyShiftCamera(-1, 0) end
    if key == "right" and not isRepeat then cameraHandler.keyShiftCamera(1, 0) end
    if key == "escape" then love.event.push("quit") end
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
                logicHandler.tileSelect(xc, yc)
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
        
        local tx, ty = cameraHandler.convertScreenCoordinates(x, y)
        local tile = world.getTile(tx, ty)
        if tile then
            --local char = world.getChar(1)
            --char.state = "idle"
            --char.target = {x=math.floor(tx), y=math.floor(ty)}
        end
    end
    
    if button == "wu" then cameraHandler.zoomIn() end
    if button == "wd" then cameraHandler.zoomOut() end
end
