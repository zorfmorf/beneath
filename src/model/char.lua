--[[
    
    Any animated character in the game. Currently only represents villagers, but may be split up in the future
    
]]--

CHAR_ID = 1

local ANIM_SPEED = 10
local WALK_SPEED = 1.5

Char = class()

Char.__name = "char"

function Char:__init(l, x, y)
    self.l = l
    self.x = x
    self.y = y
    self.state = "idle"
    self.anim = "walk"
    self.name = "Lysa Thorne"
    self.visible = true -- on by default
    self.direction = "d"
    self.animcycle = 1
    self.idletime = 0
    self.id = CHAR_ID
    CHAR_ID = CHAR_ID + 1
    self.task = nil
    self.path = nil
end

function Char:addTask(task)
    
    -- if we are client and the current
    -- task is not finished, finish it
    if not server and self.task then
        self.task:clientFinish(self)
    end
    
    self.state = "idle"
    self.anim = "walk"
    self.animcycle = 1
    self.path = nil
    self.task = task
end

function Char:updateAnimation(dt)
    self.animcycle = self.animcycle + dt * ANIM_SPEED
    if self.animcycle >= 9 or self.state == "idle" 
        or (self.state == "work" and self.animcycle >= 6) then 
        self.animcycle = 1
    end
end

function Char:walk(target, dt)
    if self.x < target.x then self.x = math.min(target.x, self.x + WALK_SPEED * dt) self.direction = "r" return end
    if self.x > target.x then self.x = math.max(target.x, self.x - WALK_SPEED * dt) self.direction = "l" return end
    if self.y < target.y then self.y = math.min(target.y, self.y + WALK_SPEED * dt) self.direction = "d" end
    if self.y > target.y then self.y = math.max(target.y, self.y - WALK_SPEED * dt) self.direction = "u" end
end

function Char:update(dt)
    
    self:updateAnimation(dt)
    
    if self.state == "blocked" then
        --print("Help I'm blocked")
    end
    
    if self.state == "work" then
        
        if self.task and not self.task:isCompleted() then
            
            local target = self.task:getTarget()
        
            local tx = target.x
            local ty = target.y + 0.5
                
            self.direction = "r"
            self.anim = "work"
            local change = self.task:doWork(self, dt)
            if change then
                self.state = "idle"
                self.anim = "walk"
                self.path = nil
            end
            
        else
            self:addTask(nil)
        end
    end
    
    if self.state == "walk" then
        
        if self.path == nil then
            self:generatePath()
            return
        end
        
        if #self.path == 0 then
            self.path = nil
            self.animcycle = 1
            self.state = "work"
            
            local taskTarget = self.task:getTarget()
            if taskTarget then
                local xdif = self.x - taskTarget.x
                local ydif = self.y - taskTarget.y
                if math.abs(ydif) > math.abs(xdif) then
                    self.direction = "d"
                    if ydif > 0 then self.direction = "u" end
                else
                    self.direction = "r"
                    if xdif > 0 then self.direction = "l" end
                end
            else
                self:addTask(nil)
            end
            return
        end
        
        local target = self.path[1]
        
        -- check if we need to recalculate paths
        if #self.path > 0 then
            if world.getTile(self.l, target.x, target.y).object then
                self.path = nil
                if world.getTile(self.l, self.x, self.y).object and
                   world.getTile(self.l, self.x + 1, self.y).object and
                   world.getTile(self.l, self.x - 1, self.y).object and
                   world.getTile(self.l, self.x, self.y + 1).object and
                   world.getTile(self.l, self.x, self.y - 1).object then
                    self.state = "blocked"
                end
                return
            end
        end
        
        self:walk(target, dt)
        
        if self.x == target.x and self.y == target.y then
            table.remove(self.path, 1)
        end
        
    end
    
    if self.state == "idle" then
        
        if self.task then self.state = "walk" return end
        
        if server then
            self.idletime = self.idletime - dt
            if self.idletime <= 0 then
                self.task = taskHandler.getTask() 
                if not self.task then
                    self.idletime = 2
                end
            end
        end
        
        if self.task then
            
            self:generatePath()
            if self.path then 
                if server then server.sendNewCharTask(self) end
            else
                if server then 
                    taskHandler.giveBackTask(self.task)
                    self.idletime = math.random() * 5
                end
                self.task = nil
            end
            
        end
    end
end

function Char:generatePath()
    local target = self.task:getTarget()
    self.path = astar.calculate(
            { l=self.l, x=math.floor(self.x), y=math.floor(self.y) }, 
            { l=target.l, x=math.floor(target.x), y=math.floor(target.y)}
        )
    if self.path then
        if self.path[1] then
            
            local tile = world.getTile(self.l, self.path[1].x, self.path[1].y)
            if not tile then print("Invalid path tile:", self.l, self.path[1].x, self.path[1].y) end
            if tile.object then
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
        print( "Path not createable", target.l, target.x, target.y )
    end
end

function Char:getAnimation()
    if self.state == "blocked" then return "walk_d1" end
    return self.anim.."_"..self.direction..math.floor(self.animcycle)
end
