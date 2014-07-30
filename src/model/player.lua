--[[
    
    Used to keep track between different factions
    There will be ai players somewhere in the future
    
]]--

PLAYER_ID = 1

Player = class()

Player.__name = "player"

function Player:__init(index)
    self.id = PLAYER_ID
    PLAYER_ID = PLAYER_ID + 1
    self.name = "Anonymous"
    self.connection_id = index
end