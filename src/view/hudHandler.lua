--[[
    
    Tasked with drawing everything hud related
    
--]]


hudHandler = {}

local cursor = nil -- current cursor icon
local cursor_color = {255, 255, 255, 255}
local buildcontainer = nil

local iconCarpenter = love.graphics.newImage( "ressource/icons/carpenter.png" )
local iconWarehouse = love.graphics.newImage( "ressource/icons/warehouse.png" )
local iconHole = love.graphics.newImage( "ressource/icons/hole.png" )

function hudHandler.init()
    
    local panels = {}
    panels[1] = {}
    panels[1].icon = iconCarpenter
    panels[1].x = 0
    panels[1].y = 0
    panels[1].name = Carpenter.__name
    local scrolls = { Scroll:new( { { icon=iconHole, x=0, y=0, name=Hole.__name } } ), 
                      Scroll:new( { { icon=iconWarehouse, x=0, y=0, name=Warehouse.__name } } ), 
                      Scroll:new( panels ) }
    
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
        cursor.l = cameraHandler.getLayer()
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

-- returns true if the mouse is hovering over hud items,
-- if true handles mouse click event as wel
function hudHandler.catchMouseClick(x, y)
    return buildcontainer:catchMouseClick(x, y)
end

function hudHandler.getCursor()
    return cursor
end

function hudHandler.setCursor(newc)
    cursor = newc
end

function hudHandler.getCursorColor()
    return cursor_color
end


-- When the build menu changes we should redraw all scrolls
function hudHandler.redrawScrolls()
    buildcontainer:redraw()
end


function hudHandler.draw()
    love.graphics.origin()
    
    love.graphics.setColor(255, 255, 255, 255)
    buildcontainer:draw()
    
end

function hudHandler.dim()
    love.graphics.origin()
    love.graphics.setColor(0, 0, 0, 100)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end
