--[[
    
    Most buildings require a specialized villager
    to work in it. On build completion, a free villager
    will take up the required profession and residence
    
]]--

Profession = Char:extends()

function Profession:__init(char)
    self.x = char.x
    self.y = char.x
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

-- Carpenter char ... wow that name is so stupd :D
Charpenter = Profession:extends()

function Charpenter:__init(char)
    self.super.__init(self, char)
    self.name = "<Carpenter> " .. char.name
end