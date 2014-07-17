--[[
    
    A container is attached to a side of the screen and contains
    a set of scrolls to be displayed there (maybe more later)
    
    TODO: add atach modes and alignment (left/right/top/bottom)
    
]]--

Container = class()
Container.__name = "container"

function Container:__init(items)
    self.items = items
    self.padding = 10 -- padding between items
    self.pad = 50 -- padding to the side (before items)
    self:refresh()
end

-- notify container to update item positions
function Container:refresh()
    local wacc = 0 -- width accumulator
    for i,element in ipairs(self.items) do
        wacc = wacc + element:getWidth()
        element:setPos( love.graphics.getWidth() - (self.pad + (i-1) * self.padding + wacc), love.graphics.getHeight() )
    end
end

function Container:draw()
    local wacc = 0 -- width accumulator
    for i,element in ipairs(self.items) do
        element:draw()
    end
end

function Container:update(dt)
    for i,element in ipairs(self.items) do
        element:update(dt)
    end
end