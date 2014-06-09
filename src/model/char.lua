
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
    self.name = "Lysa Thorne"
    self.direction = "d"
    self.animcycle = 1
    self.idletime = 0
    self.id = CHAR_ID
    CHAR_ID = CHAR_ID + 1
    self.target = nil
    self.path = nil
end

function Char:update(dt)
    self.animcycle = self.animcycle + dt * ANIM_SPEED
    if self.animcycle >= 9 or self.state == "idle" 
        or (self.state == "work" and self.animcycle >= 6) then 
        self.animcycle = 1
    end
    
    if self.state == "work" then
        self.target.workleft = self.target.workleft - dt
        self.target:work()
        if self.target.workleft < 0 then
            self.target.selected = false
            self.target = nil
            self.state = "idle"
            self.anim = "walk"
        end
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
            self.state = "work"
            self.anim = "work"
            self.animcycle = 1
            local xdif = self.x - self.target.x
            local ydif = self.y - self.target.y
            if math.abs(ydif) > math.abs(xdif) then
                self.direction = "d"
                if ydif > 0 then self.direction = "u" end
            else
                self.direction = "r"
                if xdif > 0 then self.direction = "l" end
            end
        end
        
    end
    
    if self.state == "idle" then
        
        if self.target then
            local tile = world.getTile(self.x, self.y)
            self.path = astar.calculate(
                    world.getTiles(), 
                    {
                        x=math.floor(self.x), 
                        y=math.floor(self.y)
                    }, 
                    {
                        x=math.floor(self.target.x), 
                        y=math.floor(self.target.y)
                    }
                )
            if self.path then
                self.state = "walk"
            else
                print( "Path not creatable" )
                self.target.selected = false
                self.target = nil
            end
        else
            self.idletime = self.idletime - dt
            if self.idletime <= 0 then
                self.target = taskHandler.getTask()
                if self.target == nil then
                    self.idletime = math.random() * 3
                end
            end
        end
    end
end

function Char:getAnimation()
    return self.anim.."_"..self.direction..math.floor(self.animcycle)
end