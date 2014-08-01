class = require 'lib/30logclean'
require 'lib/misc'

require 'control/gameCreator'
require 'control/gameInputHandler'
require 'control/logicHandler'
require 'control/ressourceHandler'
require 'misc/astar'
require 'misc/charsetParser'
require 'misc/tilesetParser'
require 'misc/overlayGenerator'
require 'misc/printHelper'
require 'model/char'
require 'model/chunk'
require 'model/object'
require 'model/building'
require 'model/player'
require 'model/profession'
require 'model/task'
require 'model/world'
require 'networking/client'
require 'networking/parser'
require 'view/cameraHandler'
require 'view/consoleHandler'
require 'view/drawHandler'
require 'view/hudHandler'
require 'view/elements/clickable'
require 'view/elements/container'
require 'view/elements/scroll'

--- menu includes

require 'menu/lobby'
require 'menu/menu'
require 'menu/menuHandler'

function love.load()
    
    state = "menu"
    displayMenu = false
    
    menuHandler.init()
end


function love.update(dt)
    
    if state == "menu" or displayMenu then
        menuHandler.update(dt)
    end
    
    if state == "ingame" then
        world.update(dt)
        if not displayMenu then hudHandler.update(dt) end
        gameInputHandler.update(dt)
        client.service()
        if console then consoleHandler.update(dt) end
    end
    
    if state == "lobby" then
        lobby.update(dt)
        client.service()
    end
    
end


function love.draw()
    
    if state == "ingame" then
    
        drawHandler.drawTerrain()
        if displayMenu then
            hudHandler.dim()
        else
            hudHandler.draw() 
        end
        
        if console then consoleHandler.draw() end
    end
    
    if state == "menu" or displayMenu then
        menuHandler.draw()
    end
    
    if state == "lobby" then
        lobby.draw()
    end
    
end


function love.keypressed(key, isRepeat)
    
    if state == "lobby" then
        lobby.keypressed(key, isRepeat)
    end
    
    if state == "menu" or displayMenu then
        menuHandler.keypressed(key, isRepeat)
        return
    end
    
    if state == "ingame" then
        gameInputHandler.keypressed(key, isRepeat)
    end
    
end


function love.keyreleased(key, isRepeat)
    
    if state == "menu" or displayMenu then
        menuHandler.keyreleased(key, isRepeat)
        return
    end
    
    if state == "ingame" then
        gameInputHandler.keyreleased(key, isRepeat)
    end
    
end


function love.mousepressed(x, y, button)
    
    if state == "menu" or displayMenu then
        menuHandler.mousepressed(x, y, button)
        return
    end
    
    if state == "ingame" then
        gameInputHandler.mousepressed(x, y, button)
    end
    
end


function love.mousereleased(x, y, button)
    
    if state == "menu" or displayMenu then
        menuHandler.mousereleased(x, y, button)
        return
    end
    
    if state == "ingame" then
        gameInputHandler.mousereleased(x, y, button)
    end
    
end
