
consoleHandler = {}

function consoleHandler.init()
    
end

function consoleHandler.update(dt)
    
end

function consoleHandler.draw()
    
    love.graphics.setColor(255, 255, 255, 255)
    
    love.graphics.print("FPS ".. love.timer.getFPS(), 0, 0)
    
end
