
menuInputHandler = {}

function menuInputHandler.update(dt)
    
end


function menuInputHandler.keypressed(key, isRepeat)
    if key == "return" then
        mainMenu.fire()
    end
    if key == "up" then
        mainMenu.goUp()
    end
    if key == "down" then
        mainMenu.goDown()
    end
    if key == "escape" then
        if displayMenu then 
            displayMenu = false
        else
            love.event.push("quit")
        end
    end
end


function menuInputHandler.keyreleased(key, isRepeat)
    
end


function menuInputHandler.mousereleased(x, y, button)
    
end


function menuInputHandler.mousepressed(x, y, button)
    
end
