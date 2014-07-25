--[[
    
    The console is primarly used to display debug information
    
]]--

consoleHandler = {}

local font = love.graphics.newFont(14)

function consoleHandler.init()
    
end

function consoleHandler.update(dt)
    
end

function consoleHandler.draw()
    
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(font)
    
    love.graphics.print("FPS ".. love.timer.getFPS(), 0, 0)
    love.graphics.print("Layer: ".. cameraHandler.getLayer(), 0, 20)
    
end
