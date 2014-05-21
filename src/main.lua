class = require 'lib/30logclean'
require 'lib/misc'

require 'control/inputHandler'
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
    
    world = World()
end


function love.update(dt)
    hudHandler.update(dt)
end


function love.draw()
    
    drawHandler.drawTerrain()
    hudHandler.draw()
    
    if console then consoleHandler.draw() end
    
end


function love.keypressed(key, isRepeat)
    if key == "up" and not isRepeat then cameraHandler.shiftCamera(0, -1) end
    if key == "down" and not isRepeat then cameraHandler.shiftCamera(0, 1) end
    if key == "left" and not isRepeat then cameraHandler.shiftCamera(-1, 0) end
    if key == "right" and not isRepeat then cameraHandler.shiftCamera(1, 0) end
    if key == "escape" then love.event.push("quit") end
    if key == "f1" then console = not console end
end


function love.keyreleased(key, isRepeat)
    
end


function love.mousepressed(x, y, button)
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
