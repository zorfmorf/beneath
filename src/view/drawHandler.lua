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
    
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(world.getTerrainCanvas(), tilesize, tilesize)
    
    love.graphics.setColor(100, 0, 0, 100)
    for y,row in pairs(world.getTiles()) do
        for x,tile in pairs(row) do
            
            if tile.object ~= nil and console then
                love.graphics.rectangle("fill", x * tilesize, y * tilesize, tilesize, tilesize)
            end
            
        end
        
    end
    
    
    love.graphics.setColor(255, 255, 255, 255)
    
    local char = world.getChar(1)
    if console and char and char.path then
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
            
            love.graphics.setColor(255, 255, 255, 255)
            if obj.selected then love.graphics.setColor(255, 150, 150, 255) end
            
            if obj.mesh then
                love.graphics.draw(obj.mesh, obj.x * tilesize, obj.y * tilesize, 0, 1, 1, obj.xshift * tilesize, obj.mesh:getImage():getHeight() - tilesize * (1 - obj.yshift))
            else if obj.image then
                    local image = objects[obj.image]
                    love.graphics.draw(image, obj.x * tilesize, obj.y * tilesize, 0, 1, 1, obj.xshift * tilesize, image:getHeight() - tilesize * (1 - obj.yshift))
                end
            end
            
            if obj.ressources then
                for i,res in pairs(obj.ressources) do
                    love.graphics.draw(objects[i..res], obj.x * tilesize, obj.y * tilesize)
                end
            end
            if console then love.graphics.rectangle("line", obj.x * tilesize, obj.y * tilesize, tilesize, tilesize) end
            i = i + 1
        else
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.setFont(nameFont)
            love.graphics.print(char.name, char.x * tilesize, char.y * tilesize, 0, 1, 1, nameFont:getWidth(char.name) / 2, 64)
            if anim_quad[char:getAnimation()] then
                love.graphics.draw(charset, anim_quad[char:getAnimation()], char.x * tilesize, char.y * tilesize, 0, 1, 1, 32, 58)
            else
                print("Anim missing:", char:getAnimation(), char.state, char.anim, char.animcycle)
            end
            j = j + 1
        end
    end
    
    local mx, my = love.mouse.getPosition()
    if not love.mouse.isVisible() then
        local tx, ty = cameraHandler.convertScreenCoordinates(mx, my)
        tx = math.floor(tx)
        ty = math.floor(ty)
        local cursor = hudHandler.getCursor()
        local img = objects[cursor.image]
        love.graphics.setColor(hudHandler.getCursorColor())
        love.graphics.draw(img, tx * tilesize, ty * tilesize, 0, 1, 1, cursor.xshift * tilesize, img:getHeight() - tilesize * (1 - cursor.yshift))
    end
    
end