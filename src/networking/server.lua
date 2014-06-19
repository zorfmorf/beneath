--[[
    
    Handles all network communication with connected clients
    
]]--

require "enet"

server = {}

local host = nil


-- bind to port and be ready to recieve connections
function server.init()
    host = enet.host_create"localhost:44631"
end


-- check for and handle incoming messages
function server.service()
    local event = host:service(0)
    while event do
        
        if event.type == "connect" then
            logfile:write( "Client connected:", event.peer:index(), event.peer:connect_id(), "\n" )
            server.sendGameState(event.peer)
        end
        
        if event.type == "receive" then
            logfile:write( "Client", event.peer:index(), ":,", event.data, "\n" )
            event.peer:send(event.data)
        end
        event = host:service(0)
    end
end


-- send the whole game state
function server.sendGameState(peer)
    server.sendTiles(peer)
    server.sendObjects(peer)
    server.sendChars(peer)
end


-- send all tiles
function server.sendTiles(peer)
    local tiles = "tiles "
    for i,row in pairs(world.getTiles()) do
        for j,tile in pairs(row) do
            tiles = tiles..tile.texture
            if j < #row then tiles = tiles .. "," end
        end
        tiles = tiles..";"
    end
    peer:send(tiles)
end


-- send all objects
function server.sendObjects(peer)
    local objstr = "plobj "
    for i,object in pairs(world.getObjects()) do
        objstr = objstr..object.id..","..object.__name..","..object.x..","object.y..";"
    end
    peer:send(objstr)
end


-- send all chars
function server.sendChars(peer)
    
end