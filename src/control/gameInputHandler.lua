
gameInputHandler = {}

function gameInputHandler.keypressed(key, isRepeat)
    if key == "up" and not isRepeat then cameraHandler.shiftCamera(0, -1) end
    if key == "down" and not isRepeat then cameraHandler.shiftCamera(0, 1) end
    if key == "left" and not isRepeat then cameraHandler.shiftCamera(-1, 0) end
    if key == "right" and not isRepeat then cameraHandler.shiftCamera(1, 0) end
    if key == "escape" then love.event.push("quit") end
    if key == "f1" then console = not console end
end


function gameInputHandler.keyreleased(key, isRepeat)
    
end


function gameInputHandler.mousepressed(x, y, button)
    if button == "l" then
        
        if not hudHandler.catchMouseClick(x, y) then
            local xc, yc = cameraHandler.convertScreenCoordinates(x, y)
            logicHandler.tileSelect(xc, yc)
        end
        
    end
    
    if button == "r" then
        logicHandler.deselect()
    end
    
    if button == "wu" then cameraHandler.zoomIn() end
    if button == "wd" then cameraHandler.zoomOut() end
end
