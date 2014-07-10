--[[
    
    Tasked with drawing everything hud related
    
--]]


hudHandler = {}

local active = false -- if not active, sidebar is deactivaed
local sidebarCanvas = nil -- the canvas containing the sidebar bkg
local sidebarslidespeed = 200
local sideshift = 0 -- current sidebar shift
local width = 0 -- max sidebar width
local cursor = nil -- current cursor icon
local cursor_color = {255, 255, 255, 255}

function hudHandler.init()
    
    active = false
    width = tilesize * 2
    sideshift = 0
    
    local th = math.floor(love.graphics.getHeight() / tilesize + 1)
    sidebarCanvas = love.graphics.newCanvas(tilesize * 3, th * tilesize)
    love.graphics.setCanvas(sidebarCanvas)
    for i=0,3 do
        for j=0,th-1 do
            local rand = math.random(1, 15)
            if rand > 4 then rand = 1 end
            love.graphics.draw(terrain["stone"..rand], 
                (0.5 + i) * tilesize, j * tilesize)
        end
    end
    for j=0,th-1 do
        love.graphics.draw(terrain["col_mid1"], 0, j * tilesize)
    end
    love.graphics.draw(terrain["col_mid2"], 0, 7 * tilesize)
    love.graphics.draw(terrain["col_mid3"], 0, 8 * tilesize)
    love.graphics.draw(terrain["col_mid4"], 0, (th-4) * tilesize)
    love.graphics.setCanvas()
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
                local scale = (tilesize * 2) / item:getWidth()
                
                local yvalue = i * 5 + yshift
                
                if y > yvalue and y < yvalue + item:getHeight() * scale then
                    love.mouse.setVisible(false)
                    
                    local object = Object:new()
                    
                    if builditem.__name == "tree_small" then object = Tree:new() end
                    if builditem.__name == "tent" then object = Tent:new() end
                    if builditem.__name == "farm" then object = Farm:new() end
                    if builditem.__name == "smith" then object = Smith:new() end
                    if builditem.__name == "warehouse" then object = Warehouse:new() end
                    cursor = object
                    logicHandler.switchToBuildMode(object)
                    
                    return true
                end
                yshift = item:getHeight()  * scale 
            end
        end
        return true
    end
    return false
end

function hudHandler.getCursor()
    return cursor
end

function hudHandler.getCursorColor()
    return cursor_color
end

function hudHandler.draw()
    love.graphics.origin()
    
    local xpos = love.graphics.getWidth() - sideshift
    love.graphics.setColor(255, 255, 255, 255)
    
    -- draw sidebar
    love.graphics.draw(sidebarCanvas, love.graphics.getWidth() - tilesize - sideshift)
    
    -- draw mouse build icon
    local mx, my = love.mouse.getPosition()
    local scale = cameraHandler.getZoom()
    
    -- draw buildables    
    local builditems = logicHandler.getBuildItems()
    local yshift = 0
    for i,item in pairs(builditems) do
        
        local image = objects[item.image]
        
        local scale = (tilesize * 2) / image:getWidth()
        
        local yvalue = i * 5 + yshift
        
        if mx > xpos and my > yvalue and my < yvalue + image:getHeight() * scale then
            love.graphics.setColor(230, 150, 150, 255)
        else
            love.graphics.setColor(255, 255, 255, 255)
        end
        
        love.graphics.draw(image, xpos, yvalue, 0, scale, scale)
        yshift = yshift + image:getHeight() * scale
    end
    
end