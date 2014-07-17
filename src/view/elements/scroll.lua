--[[
    
    Scrolls are menu elements that are attached to lower or upper screen border.
    They contain clickable element and/or text items.
    
    They unfold on mouse over and retract when the mouse moves away
    
]]--

local scrollspeed = 5

-- image ressource
local tiles = {}
local source = love.image.newImageData( "ressource/ui/ui.png" )
local imgData = love.image.newImageData(tilesize, tilesize)

-- source coordinates
local sx = 10
local sy = 0

for i=1,3 do
    tiles[i] = {}
    for j=1,3 do
        imgData:paste(source, 0, 0, (sx+j) * tilesize, (sy + i) * tilesize, tilesize, tilesize)
        tiles[i][j] = love.graphics.newImage(imgData)
    end
end

local function generateCanvas(width, height)
    local canvas = love.graphics.newCanvas( width * tilesize, height * tilesize)
    love.graphics.setCanvas(canvas)
    for i=1,height do
        for j=1,width do
            
            local xc = 2
            if j == 1 then xc = 1 end
            if j == width then xc = 3 end
                    
            
            local yc = 2
            if i == 1 then yc = 1 end
            if i == height then yc = 3 end
              
            love.graphics.draw(tiles[yc][xc], (j-1) * tilesize, (i-1) * tilesize)
        end
    end
    love.graphics.setCanvas()
    return canvas
end

-- Actual Scroll implementation
Scroll = class()
Scroll.__name = "scroll"


function Scroll:__init( items )
    local w = 2
    local h = 2
    self.items = items
    for i,item in ipairs(self.items) do
        w = math.max(w, 1 + math.floor(item.icon:getWidth() / tilesize) )
        h = h + math.floor(item.icon:getHeight() / tilesize)
    end
    self.canvas = generateCanvas(w, h)
    self.shift = 0
    self.mouseover = false
    self.x = 0
    self.y = 0
end


function Scroll:generateY()
    return self.y - (self.canvas:getHeight() - tilesize * 2 ) * self.shift - tilesize
end


-- unravel or close scroll depending on mouse position
function Scroll:update(dt)
    
    local x, y = love.mouse.getPosition()

    self.mouseover = x >= self.x and x < self.x + self.canvas:getWidth() and y > self:generateY()
    
    if self.mouseover then
        self.shift = math.min(1, self.shift + dt * scrollspeed)
    else
        self.shift = math.max(0, self.shift - dt * scrollspeed)
    end
    
    local yacc = tilesize
    for i,item in ipairs(self.items) do
        item.x = self.x + tilesize * 0.45
        item.y = self:generateY() + yacc
        yacc = yacc + item.icon:getHeight()
    end
    
end


-- draws scroll canvas and then all items in the scroll
function Scroll:draw()
    love.graphics.draw(self.canvas, self.x, self:generateY() )
    for i,item in ipairs(self.items) do
        love.graphics.draw(item.icon, item.x, item.y)
    end
end


function Scroll:getWidth()
    return self.canvas:getWidth()
end


-- used by container to rearrange items
function Scroll:setPos(x, y)
    self.x = x
    self.y = y
end


-- return true if mouse hovers over scroll
-- if true check if the mouse click is on any item
function Scroll:catchMouseClick(x, y) 
    if x >= self.x and x <= self.x + self:getWidth() and y >= self:generateY() then
        for i,item in ipairs(self.items) do
            if x >= item.x and x <= item.x + item.icon:getWidth() and y >= item.y and y <= item.y + item.icon:getHeight() then
                
                love.mouse.setVisible(false)
                
                local object = Object:new()
                if item.__name == "tree_small" then object = Tree:new() end
                if item.__name == "tent" then object = Tent:new() end
                if item.__name == "farm" then object = Farm:new() end
                if item.__name == "field" then object = Field:new() end
                if item.__name == "smith" then object = Smith:new() end
                if item.__name == "warehouse" then object = Warehouse:new() end
                if item.name == Carpenter.__name then object = Carpenter:new() end
                
                hudHandler.setCursor( object )
                logicHandler.switchToBuildMode(object)
                return true
            end
        end
        return true
    end
    return false
end
