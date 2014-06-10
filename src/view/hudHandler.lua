
hudHandler = {}

local sidebarseed = {} -- randomseed for sidebar so that it looks always the same
local active = false -- if not active, sidebar is deactivaed
local sidebarslidespeed = 200
local sideshift = 0 -- current sidebar shift
local width = 0 -- max sidebar width
local cursor = nil -- current cursor icon
local cursor_color = {255, 255, 255, 255}

function hudHandler.init()
    
    active = false
    width = tilesize * 2
    sideshift = 0
    
    for i=1,500 do
        sidebarseed[i] = math.random(1, 8)
        if sidebarseed[i] > 5 then sidebarseed[i] = 1 end
    end
end

-- make hud visible again
function hudHandler.activate()
    cursor = nil
    love.mouse.setVisible(true)
end

function hudHandler.update(dt)
    
    if active and sideshift < width then
        sideshift = math.min(sideshift + dt * sidebarslidespeed, width)
    end
    
    if not active and sideshift > 0 then
        sideshift = math.max(sideshift - dt * sidebarslidespeed, 0)
    end
    
    local x = love.mouse.getX()
    if logicHandler.isInFreeMode() and x > love.graphics.getWidth() - (sideshift + tilesize) then
        active = true
    else
        active = false
    end
    
    -- if in placemode check if placable
    if cursor then
        local x, y = cameraHandler.convertScreenCoordinates( love.mouse.getPosition() )
        cursor.x = x
        cursor.y = y
        if world.isPlacable(cursor) then
            cursor_color = {120, 255, 120, 255}
        else
            cursor_color = {255, 120, 120, 255}
        end
    end
    
end

-- returns true if the mouse is hovering over hud items
function hudHandler.catchMouseClick(x, y)
    if active and x > love.graphics.getWidth() - (sideshift + tilesize) then
        if x > love.graphics.getWidth() - sideshift then
            
            local builditems = logicHandler.getBuildItems()
            local yshift = 0
            for i,builditem in pairs(builditems) do
                
                local item = objects[builditem.image]
                
                local yvalue = i * 5 + yshift
                
                if y > yvalue and y < yvalue + item:getHeight() then
                    love.mouse.setVisible(false)
                    
                    local object = Object:new()
                    
                    if builditem.__name == "tree_small" then object = Tree:new() end
                    if builditem.__name == "tent" then object = Tent:new() end
                    cursor = object
                    logicHandler.switchToBuildMode(object)
                    
                    return true
                end
                yshift = item:getHeight()
            end
        end
        return true
    end
    return false
end

function hudHandler.draw()
    love.graphics.origin()
    
    local xpos = love.graphics.getWidth() - sideshift
    love.graphics.setColor(255, 255, 255, 255)
    
    -- draw sidebar
    local y = 0
    local seedIndex = 1
    while y * tilesize < love.graphics.getHeight() do
        for i=1,3 do
            love.graphics.draw(terrain["stone"..math.max(sidebarseed[seedIndex + i] % 5, 1)], 
                xpos + (i - 1.5) * tilesize, y * tilesize)
        end
        love.graphics.draw(terrain["col_mid"..sidebarseed[seedIndex]], xpos - tilesize, y * tilesize)
        y = y + 1
        seedIndex = seedIndex + 4
    end
    
    -- draw mouse build icon
    local mx, my = love.mouse.getPosition()
    local scale = cameraHandler.getZoom()
    if not love.mouse.isVisible() then
        local tx, ty = cameraHandler.convertScreenCoordinates(mx, my)
        local t2x, t2y = cameraHandler.convertWorldCoordinates(math.floor(tx), math.floor(ty))
        local img = objects[cursor.image]
        love.graphics.setColor(cursor_color)
        love.graphics.draw(img, t2x, t2y, 0, scale, scale, cursor.xshift * tilesize, img:getHeight() - tilesize * (1 - cursor.yshift))
    end
    
    -- draw buildables    
    local builditems = logicHandler.getBuildItems()
    local yshift = 0
    for i,item in pairs(builditems) do
        
        local image = objects[item.image]
        
        local scale = (tilesize * 2) / image:getWidth()
        
        local yvalue = i * 5 + yshift
        
        if mx > xpos and my > yvalue and my < yvalue + image:getHeight() then
            love.graphics.setColor(230, 150, 150, 255)
        else
            love.graphics.setColor(255, 255, 255, 255)
        end
        
        love.graphics.draw(image, xpos, yvalue, 0, scale, scale)
        yshift = yshift + image:getHeight() * scale
    end
    
end