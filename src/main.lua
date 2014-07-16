
-- game includes

class = require 'lib/30logclean'
require 'lib/misc'

require 'control/gameInputHandler'
require 'control/logicHandler'
require 'control/ressourceHandler'
require 'misc/astar'
require 'misc/charsetParser'
require 'misc/tilesetParser'
require 'misc/printHelper'
require 'model/char'
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

--- menu includes

require 'menu/mainMenu'
require 'menu/menuInputHandler'
require 'menu/gameCreator'

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
        hudHandler.update(dt)
        gameInputHandler.update(dt)
        client.service()
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
    
end


function love.keypressed(key, isRepeat)
    
    if state == "menu" or displayMenu then
        menuInputHandler.keypressed(key, isRepeat)
    end
    
    if state == "ingame" and not displayMenu then
        gameInputHandler.keypressed(key, isRepeat)
    end
    
end


function love.keyreleased(key, isRepeat)
    
    if state == "menu" or displayMenu then
        menuInputHandler.keyreleased(key, isRepeat)
    end
    
    if state == "ingame" and not displayMenu then
        gameInputHandler.keyreleased(key, isRepeat)
    end
    
end


function love.mousepressed(x, y, button)
    
    if state == "menu" then
        menuInputHandler.mousepressed(x, y, button)
    end
    
    if state == "ingame" then
        gameInputHandler.mousepressed(x, y, button)
    end
    
end


function love.mousereleased(x, y, button)
    
    if state == "menu" then
        menuInputHandler.mousereleased(x, y, button)
    end
    
    if state == "ingame" then
        gameInputHandler.mousereleased(x, y, button)
    end
    
end