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
            logfile:write( "Client ", event.peer:index(), ": ", event.data, "\n" )
            
            if event.data:sub(1, 6) == "build " then
                server.parseBuild( event.data:sub(7) )
            end
        end
        event = host:service(0)
    end
end


-- parse a list of planned builds from client
-- try to build them and update client if it worked out
function server.parseBuild(string)
    for i,object in pairs( parser.parseObjects(string) ) do        
        local result = world.addObject(object)
        if result then
            server.sendToPeers("plobj "..parser.parseObjectsToString( { object } ))
        end
    end
end


-- send the given message to all peers
function server.sendToPeers(message)
    for i=1,host:peer_count() do
        local peer = host:get_peer(i)
        if peer:state() == "connected" then
            peer:send(message)
        end
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
    peer:send( "plobj "..parser.parseObjectsToString( world.getObjects() ) )
end


-- send all chars
function server.sendChars(peer)
    local charstr = "chars "
    for i,char in pairs(world.getChars()) do
        charstr = charstr..char.name..","..char.id..","..char.x..","..char.y..";"
    end
    peer:send(charstr)
end