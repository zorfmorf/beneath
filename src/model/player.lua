--[[
    
    Used to keep track between different factions
    There will be ai players somewhere in the future
    
]]--

Player = class()

Player.__name = "player"

function Player:__init(index)
    self.name = "Anonymous"
    self.connection_id = index
end