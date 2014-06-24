
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

function Char:addTask(target)
    self.state = "idle"
    self.anim = "walk"
    self.animcycle = 1
    self.path = nil
    self.target = target
end

function Char:update(dt)
    self.animcycle = self.animcycle + dt * ANIM_SPEED
    if self.animcycle >= 9 or self.state == "idle" 
        or (self.state == "work" and self.animcycle >= 6) then 
        self.animcycle = 1
    end
    
    if self.state == "work" then
        
        local tx = self.target.x
        local ty = self.target.y + 0.5
        
        if self.x == tx and self.y == ty then
            
            self.direction = "r"
            self.anim = "work"
            
            self.target:work(dt)
            if self.target.workleft < 0 then
                self.target.selected = false
                self:addTask(nil)
            end
            
        else
            
            if self.y > ty then
                self.y = self.y - math.min(dt, self.y - ty)
            end
            
            if self.x < tx then
                self.x = self.x + math.min(dt, tx - self.x)
            end
            
            if self.x > tx then
                self.x = self.x - math.min(dt, self.x - tx)
            end
        end
    end
    
    if self.state == "walk" then
        
        if self.path == nil then
            self.state = "idle"
            return
        end
        
        local target = self.path[1]
        
        -- check if we need to recalculate paths
        if #self.path > 0 then
            if world.getTile(target.x, target.y).object then
                self.path = nil
                if world.getTile(self.x, self.y).object and
                   world.getTile(self.x + 1, self.y).object and
                   world.getTile(self.x - 1, self.y).object and
                   world.getTile(self.x, self.y + 1).object and
                   world.getTile(self.x, self.y - 1).object then
                    self.state = "blocked"
                end
                return
            end
        end
        
        if self.y < target.y then self.y = math.min(target.y, self.y + WALK_SPEED * dt) self.direction = "d" end
        if self.y > target.y then self.y = math.max(target.y, self.y - WALK_SPEED * dt) self.direction = "u" end
        if self.x < target.x then self.x = math.min(target.x, self.x + WALK_SPEED * dt) self.direction = "r" end
        if self.x > target.x then self.x = math.max(target.x, self.x - WALK_SPEED * dt) self.direction = "l" end
        
        if self.x == target.x and self.y == target.y then
            table.remove(self.path, 1)
        end
        
        if #self.path == 0 then
            self.path = nil
            self.animcycle = 1
            self.state = "work"
            self.target.selected = false
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
                if self.path[1] then
                    if world.getTile(self.path[1].x, self.path[1].y).object then
                        table.remove(self.path, 1)
                    end
                    
                    -- fix villager "spazzing" on start
                    if #self.path >= 2 then
                        local a = self.path[1]
                        local b = self.path[2]
                        if a.y == b.y and 
                            a.x < self.x and self.x < b.x or
                            b.x < self.x and self.x < b.x then 
                            table.remove(self.path, 1)
                        end
                        if a.x == b.x and
                            a.y < self.y and self.y < b.y or
                            b.y < self.y and self.y < b.y then 
                            table.remove(self.path, 1)
                        end 
                    end
                end
                self.state = "walk"
            else
                print( "Path not createable" )
                self.target.selected = false
                if server then taskHandler.createTask(self.target) end
                self.target = nil
                self.idletime = 5
            end
        else
            self.idletime = self.idletime - dt
            if self.idletime <= 0 then
                if server then 
                    self.target = taskHandler.getTask() 
                    if self.target then
                        server.sendNewCharTask(self)
                    end
                end
                if self.target == nil then
                    self.idletime = 2
                end
            end
        end
    end
end

function Char:getAnimation()
    if self.state == "blocked" then return "walk_d1" end
    return self.anim.."_"..self.direction..math.floor(self.animcycle)
end