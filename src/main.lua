
-- game includes

class = require 'lib/30logclean'
require 'lib/misc'

require 'control/gameCreator'
require 'control/gameInputHandler'
require 'control/logicHandler'
require 'control/ressourceHandler'
require 'misc/astar'
require 'misc/charsetParser'
require 'misc/tilesetParser'
require 'misc/printHelper'
require 'model/char'
require 'model/chunk'
require 'model/object'
require 'model/building'
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
require 'menu/mainMenu'
require 'menu/menuInputHandler'

function love.load()
    
    state = "menu"
    displayMenu = false
    
    mainMenu.init()
end


function love.update(dt)
    
    if state == "menu" or displayMenu then
        mainMenu.update(dt)
    end
    
    if state == "ingame" then
        world.update(dt)
        if not displayMenu then hudHandler.update(dt) end
        gameInputHandler.update(dt)
        client.service()
    end
    
    if state == "lobby" then
        lobby.update(dt)
    end
    
end


function love.draw()
    
    if state == "ingame" then
    
        drawHandler.drawTerrain()
        hudHandler.draw()
        
        if console then consoleHandler.draw() end
    end
    
    if state == "menu" or displayMenu then
        mainMenu.draw()
    end
    
    if state == "lobby" then
        lobby.draw()
    end
    
end


function love.keypressed(key, isRepeat)
    
    if state == "menu" or displayMenu then
        menuInputHandler.keypressed(key, isRepeat)
        return
    end
    
    if state == "ingame" then
        gameInputHandler.keypressed(key, isRepeat)
    end
    
end


function love.keyreleased(key, isRepeat)
    
    if state == "menu" or displayMenu then
        menuInputHandler.keyreleased(key, isRepeat)
        return
    end
    
    if state == "ingame" then
        gameInputHandler.keyreleased(key, isRepeat)
    end
    
end


function love.mousepressed(x, y, button)
    
    if state == "menu" or displayMenu then
        menuInputHandler.mousepressed(x, y, button)
        return
    end
    
    if state == "ingame" then
        gameInputHandler.mousepressed(x, y, button)
    end
    
end


function love.mousereleased(x, y, button)
    
    if state == "menu" or displayMenu then
        menuInputHandler.mousereleased(x, y, button)
        return
    end
    
    if state == "ingame" then
        gameInputHandler.mousereleased(x, y, button)
    end
    
end
