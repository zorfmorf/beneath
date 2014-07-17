--[[
    
    Tasked with drawing everything hud related
    
--]]


hudHandler = {}

local cursor = nil -- current cursor icon
local cursor_color = {255, 255, 255, 255}
local buildcontainer = nil

function hudHandler.init()
    
    local scrolls = { Scroll:new(), Scroll:new() }
    
    buildcontainer = Container:new( scrolls )
end

-- make hud visible again
function hudHandler.activate()
    cursor = nil
    love.mouse.setVisible(true)
end

function hudHandler.update(dt)
    
    -- update ui elements
    buildcontainer:update(dt)
    
    -- if in placemode check if placable
    if logicHandler.getMouseState() == "build" or logicHandler.getMouseState() == "buildfarm1" then
        local x, y = cameraHandler.convertScreenCoordinates( love.mouse.getPosition() )
        cursor.x = x
        cursor.y = y
        if world.isPlacable(cursor) then
            cursor_color = {120, 255, 120, 255}
        else
            cursor_color = {255, 120, 120, 255}
        end
    end
    
    -- handle dynamic field size adjustment placement
    if logicHandler.getMouseState() == "buildfarm2" then
        local x, y = cameraHandler.convertScreenCoordinates( love.mouse.getPosition() )
        local buildCandidate = logicHandler.getBuildCandidate()
        local xsize = math.floor(x) - buildCandidate.x
        local ysize = buildCandidate.y - math.floor(y)
        if (ysize >= 3 or xsize >= 3) and (ysize ~= buildCandidate.ysize or xsize ~= buildCandidate.xsize) then
            buildCandidate.xsize = math.max(xsize, 3)
            buildCandidate.ysize = math.max(ysize, 3)
            buildCandidate:generateImage()
        end
    end
    
end

-- returns true if the mouse is hovering over hud items
function hudHandler.catchMouseClick(x, y)
    
    --[[
    if active and x > love.graphics.getWidth() - (sideshift + tilesize) then
        if x > love.graphics.getWidth() - sideshift then
            
            local builditems = logicHandler.getBuildItems()
            local yshift = 5
            for i,builditem in pairs(builditems) do
                
                local item = objects[builditem.image]
                local scale = (tilesize * 2) / item:getWidth()
                
                if y > yshift and y < yshift + item:getHeight() * scale then
                    love.mouse.setVisible(false)
                    
                    local object = Object:new()
                    
                    if builditem.__name == "tree_small" then object = Tree:new() end
                    if builditem.__name == "tent" then object = Tent:new() end
                    if builditem.__name == "farm" then object = Farm:new() end
                    if builditem.__name == "field" then object = Field:new() end
                    if builditem.__name == "smith" then object = Smith:new() end
                    if builditem.__name == "warehouse" then object = Warehouse:new() end
                    if builditem.__name == "carpenter" then object = Carpenter:new() end
                    cursor = object
                    logicHandler.switchToBuildMode(object)
                    
                    return true
                end
                yshift = yshift + 5 + item:getHeight()  * scale 
            end
        end
        return true
    end
    return false
    ]]--
end

function hudHandler.getCursor()
    return cursor
end

function hudHandler.getCursorColor()
    return cursor_color
end

function hudHandler.draw()
    love.graphics.origin()
    
    love.graphics.setColor(255, 255, 255, 255)
    buildcontainer:draw()
    
end