--[[
    
    A lobby visualization
    
]]--

lobby = {}

local font = love.graphics.newFont(20)


function lobby.fire()
    
end


function lobby.keypressed(key, isRepeat)
    
end


function lobby.update(dt)
    
end


function lobby.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(font)
    love.graphics.print("Lobby", 10, 10)
    if players then
        for i,player in pairs(players) do
            love.graphics.print(player.name, love.graphics.getWidth() / 2, 100 + i * font:getHeight() + 10)
        end
    end
end
