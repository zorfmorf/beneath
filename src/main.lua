class = require 'lib/30logclean'
require 'lib/misc'

require 'control/gameInputHandler'
require 'control/logicHandler'
require 'model/object'
require 'model/world'
require 'view/cameraHandler'
require 'view/consoleHandler'
require 'view/drawHandler'
require 'view/hudHandler'
require 'view/tilesetParser'


function love.load()
    
    math.randomseed(os.time())
    
    console = true
    
    tilesetParser.loadTerrain()
    cameraHandler.init()
    hudHandler.init()
    
    world.init()
end


function love.update(dt)
    hudHandler.update(dt)
    gameInputHandler.update(dt)
end


function love.draw()
    
    drawHandler.drawTerrain()
    hudHandler.draw()
    
    if console then consoleHandler.draw() end
    
end


function love.keypressed(key, isRepeat)
    gameInputHandler.keypressed(key, isRepeat)
end


function love.keyreleased(key, isRepeat)
    gameInputHandler.keyreleased(key, isRepeat)
end


function love.mousepressed(x, y, button)
    gameInputHandler.mousepressed(x, y, button)
end


function love.mousereleased(x, y, button)
    gameInputHandler.mousereleased(x, y, button)
end