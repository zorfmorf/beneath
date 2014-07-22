--[[
    
    Most buildings require a specialized villager
    to work in it. On build completion, a free villager
    will take up the required profession and residence
    
]]--

local ANIM_SPEED = 10
local WALK_SPEED = 1.5

Profession = Char:extends()

function Profession:__init(char)
    self.x = char.x
    self.y = char.y
    self.state = char.state
    self.anim = char.anim
    self.name = char.name
    self.direction = char.direction
    self.animcycle = char.animcycle
    self.idletime = char.idletime
    self.id = char.id
end

function Profession:update(dt)
    -- overwrite char default behavior
end

function Profession:gotoWork(pos, dt)
     if self.x == pos.x and self.y == pos.y then
            self.state = "work"
            self.anim = "work"
            self.direction = "r"
        else
            self.state = "walk"
            self.anim = "walk"
            if not (self.y == pos.y) then
                self:walk( { x = self.x, y = pos.y}, dt )
            else
                self:walk( pos, dt )
            end
        end
    self:updateAnimation(dt)
    self.visible = true
end

function Profession:goHome(pos, dt)
    self.state = "walk"
    self.anim = "walk"
    self:updateAnimation(dt)
    
    if not (self.x == pos.x and self.y == pos.y) then
        self:walk( pos, dt)
        return
    end
    
    self.visible = false
end

-- Carpenter char ... wow that name is so stupd :D
Charpenter = Profession:extends()

function Charpenter:__init(char)
    self.super.__init(self, char)
    self.name = "<Carpenter> " .. char.name
end
