--[[
    
    A server acting as game host for a multiplayer game
    or as internal server for single player.
    Avoids having to implement any functionality twice.
    
]]--

class = require 'lib/30logclean'
require 'lib/misc'

require 'control/gameInputHandler'
require 'control/logicHandler'
require 'control/taskHandler'
require 'misc/astar'
require 'model/char'
require 'model/object'
require 'model/world'

local server_active = true

local time = os.time()

logicHandler.init()
taskHandler.init()
world.init()

while server_active do
    
    local timeN = os.time()
    local dt = timeN - time
    time = timeN
    
    
    
end