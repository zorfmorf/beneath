
CHAR_ID = 1

local ANIM_SPEED = 10
local WALK_SPEED = 1.5

Char = class()

Char.__name = "char"

function Char:__init(x, y)
    self.x = x
    self.y = y
    self.state = "idle"
    self.anim = "walk"
    self.direction = "d"
    self.animcycle = 1
    self.id = CHAR_ID
    CHAR_ID = CHAR_ID + 1
    self.target = nil
    self.path = nil
end

function Char:update(dt)
    self.animcycle = self.animcycle + dt * ANIM_SPEED
    if self.animcycle >= 9 or self.state == "idle" then 
        self.animcycle = 1
    end
    
    if self.state == "walk" then
        
        if self.path == nil then
            self.state = "idle"
            return
        end
        
        local target = self.path[1]
        
        if self.y < target.y then self.y = math.min(target.y, self.y + WALK_SPEED * dt) self.direction = "d" end
        if self.y > target.y then self.y = math.max(target.y, self.y - WALK_SPEED * dt) self.direction = "u" end
        if self.x < target.x then self.x = math.min(target.x, self.x + WALK_SPEED * dt) self.direction = "r" end
        if self.x > target.x then self.x = math.max(target.x, self.x - WALK_SPEED * dt) self.direction = "l" end
        
        if self.x == target.x and self.y == target.y then
            table.remove(self.path, 1)
        end
        
        if #self.path == 0 then
            self.path = nil
            self.target = nil
            self.state = "idle"
        end
        
    end
    
    if self.state == "idle" then
        if self.target then
            local tile = world.getTile(self.x, self.y)
            self.path = astar.calculate(world.getTiles(), {x=math.floor(self.x), y=math.floor(self.y)}, self.target)
            if self.path then
                self.state = "walk"
            else
                self.target = nil
            end
        end
    end
end

function Char:getAnimation()
    return self.anim.."_"..self.direction..math.floor(self.animcycle)
end