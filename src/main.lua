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
require 'model/task'
require 'model/world'
require 'networking/client'
require 'networking/parser'
require 'view/cameraHandler'
require 'view/consoleHandler'
require 'view/drawHandler'
require 'view/hudHandler'

function love.load()
    
    ONLINE_GAME = false
    
    if not ONLINE_GAME then
        main_server = love.thread.newThread( "main_server.lua" )
        main_server:start()
    end
    
    math.randomseed(os.time())
    
    console = false -- while true display debug information
    
    tilesetParser.loadTerrain()
    tilesetParser.parseIcons()
    charsetParser.parseCharset()
    cameraHandler.init()
    hudHandler.init()
    logicHandler.init()
    drawHandler.init()
    world.init()
    
    client.init()
end


function love.update(dt)
    world.update(dt)
    hudHandler.update(dt)
    gameInputHandler.update(dt)
    
    client.service()
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