
drawHandler = {}

function drawHandler.drawTerrain()

    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    local scale = cameraHandler.getZoom()
    love.graphics.scale(scale, scale)
    
    love.graphics.translate( cameraHandler.getShifts() )
    
    for y,row in pairs(world.tiles) do
        
        for x,tile in pairs(row) do
            
            if x == math.floor(point.x) and y == math.floor(point.y) then
                love.graphics.setColor(255, 200, 200, 255)
            else
                love.graphics.setColor(255, 255, 255, 255)
            end
            
            love.graphics.draw(terrain[tile], (x - 1) * tilesize, (y - 1) * tilesize)
            
        end
        
    end
    
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.circle("fill", (point.x - 1) * tilesize, (point.y - 1) * tilesize, 5, 20)
    
end