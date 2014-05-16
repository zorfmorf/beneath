--[[

    Contains minor help functions to improve on lua
    
]]--

-- add startswith function to string object
startsWith = function(self, piece)
  return string.sub(self, 1, string.len(piece)) == piece
end
 
rawset(_G.string, "startsWith", startsWith)