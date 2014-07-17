--[[
    
    Scrolls are menu elements that are attached to lower or upper screen border.
    They contain clickable element and/or text items.
    
    They unfold on mouse over and retract when the mouse moves away
    
]]--

local scrollspeed = 3

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

function Scroll:__init()
    self.canvas = generateCanvas(3, 6)
    self.shift = 0
    self.mouseover = false
    self.x = 0
    self.y = 0
end

function Scroll:update(dt)
    local x, y = love.mouse.getPosition()
    
    self.mouseover = x >= self.x and x < self.x + self.canvas:getWidth() and y > self.y - (self.canvas:getHeight() - tilesize * 2) * self.shift - tilesize
    
    if self.mouseover then
        self.shift = math.min(1, self.shift + dt * scrollspeed)
    else
        self.shift = math.max(0, self.shift - dt * scrollspeed)
    end
end

function Scroll:draw()
    love.graphics.draw(self.canvas, self.x, self.y - (self.canvas:getHeight() - tilesize * 2 ) * self.shift - tilesize)
end

function Scroll:getWidth()
    return self.canvas:getWidth()
end

function Scroll:setPos(x, y)
    self.x = x
    self.y = y
end