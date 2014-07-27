--[[
    
    The console is primarly used to display debug information
    
]]--

consoleHandler = {}

local font = love.graphics.newFont(14)
local messages = {}
local width = 0

function consoleHandler.update(dt)
    messages[1] = "FPS ".. love.timer.getFPS()
    messages[2] = "Layer: ".. cameraHandler.getLayer()
    messages[3] = "Scale: " .. cameraHandler.getZoom()
    messages[4] = "Ping: " .. client.getRTT()
    
    if width == 0 then
        for i,msg in ipairs(messages) do
            width = math.max(width, font:getWidth(msg) + 10)
        end
    end
end

function consoleHandler.draw()
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), font:getHeight() + 10)
    
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(font)
    for i,msg in ipairs(messages) do
        love.graphics.print(msg, love.graphics.getWidth() -  i * width, 5)
    end
    
end
