sheark = -0.3

drawHandler = {}

function drawHandler.drawTerrain()

    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    local scale = cameraHandler.getZoom()
    love.graphics.scale(scale, scale)
    love.graphics.translate( cameraHandler.getShifts() )
    
    for y,row in pairs(world.tiles) do
        
        for x,tile in pairs(row) do
            
            if tile.object ~= nil then
                love.graphics.setColor(255, 200, 200, 255)
            else
                love.graphics.setColor(255, 255, 255, 255)
            end
            
            love.graphics.draw(terrain[tile.texture], x * tilesize, y * tilesize)
            
        end
        
    end
    
    for i,object in pairs(world.objects) do
        love.graphics.draw(objects[object.image], object.x * tilesize, object.y * tilesize, 0, 1, 1, 0, tilesize * 1.2)
    end
    
end