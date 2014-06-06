sheark = -0.3

local nameFont = nil

drawHandler = {}

function drawHandler.init()
    nameFont = love.graphics.newFont(14)
end

function drawHandler.drawTerrain()

    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    local scale = cameraHandler.getZoom()
    love.graphics.scale(scale, scale)
    love.graphics.translate( cameraHandler.getShifts() )
    
    for y,row in pairs(world.getTiles()) do
        
        for x,tile in pairs(row) do
            
            if tile.object ~= nil and console then
                love.graphics.setColor(255, 200, 200, 255)
            else
                love.graphics.setColor(255, 255, 255, 255)
            end
            
            love.graphics.draw(terrain[tile.texture], x * tilesize, y * tilesize)
            
        end
        
    end
    
    
    love.graphics.setColor(255, 255, 255, 255)
    
    if console and world.getChar(1).path then
        for i,entry in pairs(world.getChar(1).path) do
            love.graphics.circle("fill", entry.x * tilesize, entry.y * tilesize, tilesize / 4, 20)
        end
    end
    
    local objOrder, charOrder = world.getDrawOrders()
    local i = 1
    local j = 1
    while objOrder[i] ~= nil or charOrder[j] ~= nil do
        
        local obj = world.getObject(objOrder[i])
        local char = world.getChar(charOrder[j])
        
        if char == nil or (obj ~= nil and char.y > obj.y) then
            local image = objects[obj.image]
            love.graphics.draw(image, obj.x * tilesize, obj.y * tilesize, 0, 1, 1, image:getWidth() / 2, image:getHeight() - obj.ysize * tilesize / 2)
            i = i + 1
        else
            love.graphics.setFont(nameFont)
            love.graphics.print(char.name, char.x * tilesize, char.y * tilesize, 0, 1, 1, nameFont:getWidth(char.name) / 2, 64)
            love.graphics.draw(charset, anim_quad[char:getAnimation()], char.x * tilesize, char.y * tilesize, 0, 1, 1, 32, 58)
            j = j + 1
        end

    end
    
    
end