--[[
    
    A server acting as game host for a multiplayer game
    or as internal server for single player.
    Avoids having to implement any functionality twice.
    
    Can be run standalone from console. However, system
    needs a working copy of the lua enet library compiled
    for lua 5.1
    
]]--

logfile = io.open("log.txt", "w")
logfile:write("Server started \n")

class = require 'lib/30logclean'
require 'lib/misc'

require 'control/gameInputHandler'
require 'control/logicHandler'
require 'control/ressourceHandler'
require 'control/taskHandler'
require 'misc/astar'
require 'misc/printHelper'
require 'model/char'
require 'model/chunk'
require 'model/object'
require 'model/building'
require 'model/player'
require 'model/profession'
require 'model/task'
require 'model/world'
require 'networking/parser'
require 'networking/server'

require "socket" -- for time measuring purposes

logfile:write("Loaded requires \n")

SERVER_TYPE = "offline"

local params = { ... }
if params and params[1] then SERVER_TYPE = params[1] end

print( "Starting mode:", SERVER_TYPE )


-- equivalent for love.update(dt)
local function update(dt)
    if state == "ingame" then
        world.update(dt)
        taskHandler.update(dt)
    end
    server.service()
end

function main()
    
    logfile:write( "Activating server\n" )
    
    local server_active = true
    math.randomseed(os.time())
    state = "lobby" -- all servers start in lobby
    
    server.init()
    logfile:write( "Ready for incoming connections\n" )

    local time = socket.gettime()
    local starttime = time

    while server_active do
        
        local timeN = socket.gettime()
        local dt = timeN - time
        time = timeN
        
        update(dt)
        
    end
end

function error_handler( err )
    logfile:write("ERROR:", err, "\n")
    print( "ERROR:", err )
end

status = xpcall( main, error_handler )
logfile:write(status)

logfile:write( "Server shut down\n" )
logfile:close()
