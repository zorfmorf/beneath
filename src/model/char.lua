
local animspeed = 10

Char = class()

Char.__name = "char"

function Char:__init(x, y)
    self.x = x
    self.y = y
    self.anim = "walk"
    self.direction = "d"
    self.animcycle = 1
end

function Char:update(dt)
    self.animcycle = self.animcycle + dt * animspeed
    if self.animcycle >= 9 then 
        self.animcycle = 1
        if self.direction == "d" then self.direction = "r" return end
        if self.direction == "r" then self.direction = "u" return end
        if self.direction == "u" then self.direction = "l" return end 
        if self.direction == "l" then self.direction = "d" return end
    end
end

function Char:getAnimation()
    return self.anim.."_"..self.direction..math.floor(self.animcycle)
end