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
    self.pad = 5 -- padding to the side (before items)
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


-- update canvases
function Container:redraw()
    for i,element in ipairs(self.items) do
        element:redraw()
    end
end


function Container:remove(i)
    table.remove(self.items, i)
end


function Container:add(item, i)
    table.insert(self.items, i, item)
end


function Container:get(i)
    return self.items[i]
end


-- draw canvases to screen
function Container:draw()
    for i,element in ipairs(self.items) do
        element:draw()
    end
end


-- updates positions. needed for movement on hover
function Container:update(dt)
    for i,element in ipairs(self.items) do
        element:update(dt)
    end
end


-- returns true if the mouse hovers over a container item
-- if true executes mouse click as well
function Container:catchMouseClick(x, y)
    for i,element in ipairs(self.items) do
        if element:catchMouseClick(x, y) then return true end
    end
    return false
end
