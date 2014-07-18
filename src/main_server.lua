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
require 'model/object'
require 'model/building'
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


-- equivalent for love.update(dt)
local function update(dt)
    world.update(dt)
    taskHandler.update(dt)
    server.service()
end

local function createSinglePlayer()
    state = "ingame"
    ressourceHandler.init()
    logicHandler.init()
    taskHandler.init()
    world.init()
    world.generate()
end

local function createOnlineGame()
    state = "lobby"
    --ressourceHandler.init()
    --logicHandler.init()
    --taskHandler.init()
    --world.init()
    --world.generate()
end

function main()
    
    logfile:write( "Activating server\n" )
    
    local server_active = true
    math.randomseed(os.time())
    state = "off"
    
    if SERVER_TYPE == "offline" then 
        createSinglePlayer()
    else
        createOnlineGame()
    end
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