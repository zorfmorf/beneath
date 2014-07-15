--[[
    
    Draws everything game world - related
    
]]--

drawHandler = {}

sheark = -0.3

local nameFont = nil
local worldCanvas = nil -- the terrain without objects

function drawHandler.init()
    nameFont = love.graphics.newFont(14)
        
    worldCanvas = love.graphics.newCanvas(tilesize, tilesize)
    love.graphics.setCanvas(worldCanvas)
    love.graphics.setColor(200,100,100,255)
    love.graphics.rectangle("fill", 0, 0, tilesize, tilesize)
    love.graphics.setCanvas()
end


-- should be called whenever the terrain changes
function drawHandler.updateCanvas()
    local tiles = world.getTiles()
    worldCanvas = love.graphics.newCanvas(#tiles[1] * tilesize, #tiles * tilesize)
    love.graphics.setCanvas(worldCanvas)
    for y,row in pairs(tiles) do
        for x,tile in pairs(row) do
            love.graphics.draw(terrain[tile.texture], (x - 1) * tilesize, (y - 1) * tilesize)
            if tile.overlays then
                for i,texture in ipairs(tile.overlays) do
                    love.graphics.draw(terrain[texture], (x - 1) * tilesize, (y - 1) * tilesize)
                end
            end
        end
    end
    love.graphics.setCanvas()
end



function drawHandler.drawTerrain()

    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    local scale = cameraHandler.getZoom()
    love.graphics.scale(scale, scale)
    love.graphics.translate( cameraHandler.getShifts() )
    
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(worldCanvas, tilesize, tilesize)
    
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
            
            -- draw object
            
            love.graphics.setColor(255, 255, 255, 255)
            
            if obj.mesh then
                love.graphics.draw(obj.mesh, obj.x * tilesize, obj.y * tilesize, 0, 1, 1, obj.xshift * tilesize, obj.mesh:getImage():getHeight() - tilesize * (1 - obj.yshift))
            else if obj.image then
                    local image = nil
                    if obj:is(Field) then image = obj.image else image = objects[obj.image] end
                    love.graphics.draw(image, obj.x * tilesize, obj.y * tilesize, 0, 1, 1, obj.xshift * tilesize, image:getHeight() - tilesize * (1 - obj.yshift))
                end
            end
            
            if obj.ressources then
                for res,amount in pairs(obj.ressources) do
                    if not objects[res..amount] then print("Missing ressource texture:", res..amount) end
                    local resShift = 0
                    if obj.resShift[res] then resShift = obj.resShift[res] end
                    love.graphics.draw(objects[res..amount], obj.x * tilesize, obj.y * tilesize, 0, 1, 1, -resShift * tilesize, objects[res..amount]:getHeight() - 32)
                end
            end
            
            if obj.char and obj.char.visible then
                love.graphics.draw(charset, anim_quad[obj.char:getAnimation()], obj.char.x * tilesize, obj.char.y * tilesize, 0, 1, 1, 32, 58)
            end
            
            if obj.selected then 
                love.graphics.draw(icons[obj.selected], obj.x * tilesize, obj.y * tilesize, 0, 1, 1, -obj.xsize * tilesize / 2 + tilesize / 2, tilesize * 2) 
            end
            
            if console then love.graphics.rectangle("line", obj.x * tilesize, obj.y * tilesize, tilesize, tilesize) end
            i = i + 1
        else
            -- draw char
            love.graphics.setColor(255, 255, 255, 255)
            if char.visible then
                love.graphics.setFont(nameFont)
                love.graphics.print(char.name, char.x * tilesize, char.y * tilesize, 0, 1, 1, nameFont:getWidth(char.name) / 2, 64)
                if anim_quad[char:getAnimation()] then
                love.graphics.draw(charset, anim_quad[char:getAnimation()], char.x * tilesize, char.y * tilesize, 0, 1, 1, 32, 58)
                else
                    print("Anim missing:", char:getAnimation(), char.state, char.anim, char.animcycle)
                end
            end
            j = j + 1
        end
    end
    
    -- draw build preview if in placement mode
    local mx, my = love.mouse.getPosition()
    if not love.mouse.isVisible() then
        
        if logicHandler.getMouseState() == "buildfarm2" then
            love.graphics.setColor(hudHandler.getCursorColor())
            local build = logicHandler.getBuildCandidate()
            local image = build.image
            love.graphics.draw(image, build.x * tilesize, build.y * tilesize, 0, 1, 1, build.xshift * tilesize, image:getHeight() - tilesize * (1 - build.yshift))
        else
            local tx, ty = cameraHandler.convertScreenCoordinates(mx, my)
            tx = math.floor(tx)
            ty = math.floor(ty)
            local cursor = hudHandler.getCursor()
            local img = objects[cursor.image]
            love.graphics.setColor(hudHandler.getCursorColor())
            love.graphics.draw(img, tx * tilesize, ty * tilesize, 0, 1, 1, cursor.xshift * tilesize, img:getHeight() - tilesize * (1 - cursor.yshift))
        end
    end
    
end