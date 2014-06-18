--[[
    
    A server acting as game host for a multiplayer game
    or as internal server for single player.
    Avoids having to implement any functionality twice.
    
]]--

systime = os.time()

function getCurrentTime()
    return os.time() - systime
end

logfile = io.open("log.txt", "w")
logfile:write("Server started at ", getCurrentTime(), " \n")

class = require 'lib/30logclean'
require 'lib/misc'

require 'control/gameInputHandler'
require 'control/logicHandler'
require 'control/taskHandler'
require 'misc/astar'
require 'model/char'
require 'model/object'
require 'model/world'
require 'networking/server'

-- equivalent for love.update(dt)
function update(dt)
    
end

function main()
    
    local server_active = true
    local testMessage = true -- TODO remove
    local SERVER = true

    logicHandler.init()
    taskHandler.init()
    world.init()
    world.generate()
    server.init()

    logfile:write("Inits finished\n")

    local time = os.time()
    local starttime = os.time()

    logfile:write( "Activating server\n" )
    while server_active do
        
        local timeN = os.time()
        local dt = timeN - time
        time = timeN
        
        update(dt)
        if testMessage and os.time() - starttime > 10 then
            logfile:write( "AUSTRALIA ACTIVATED\n" )
            server.insult()
            testMessage = nil
        end
        server.service()
        
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