--[[
    
    Handles all network communication with connected clients
    
]]--

require "enet"

server = {}

local host = nil


-- bind to port and be ready to recieve connections
function server.init()
    host = enet.host_create("localhost:44631")
    --host:compress_with_range_coder() -- better compression
    logfile:write( "host: state", tostring(host), "\n" )
end

function server.createSinglePlayer()
    ressourceHandler.init()
    logicHandler.init()
    taskHandler.init()
    world.init()
    world.generate()
end

function server.createOnlineGame()
    --ressourceHandler.init()
    --logicHandler.init()
    --taskHandler.init()
    --world.init()
    --world.generate()
end


-- check for and handle incoming messages
function server.service()
    local event = host:service(0)
    while event do
        
        if event.type == "connect" then
            logfile:write( "Client connected:", event.peer:index(), event.peer:connect_id(), "\n" )
            
            if state == "ingame" then 
                 -- TODO: disconnect / send 
            end
            if state == "lobby" then
                if SERVER_TYPE == "offline" then
                    server.createSinglePlayer()
                    server.sendGameState(event.peer)
                    state = "ingame"
                end
                if SERVER_TYPE == "online" then
                    server.sendLobbyInformation(event.peer)
                end
            end
        end
        
        if event.type == "receive" then
            logfile:write( "Client ", event.peer:index(), ": ", event.data, "\n" )
            
            if state == "ingame" then
                if event.data:sub(1, 6) == "build " then
                    server.parseBuild( event.data:sub(7) )
                end
                
                if event.data:sub(1, 6) == "taskw " then
                    server.parseTask( event.data:sub(7) )
                end
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
            if object.buildable then 
                taskHandler.createTask(object) 
            end
        end
    end
end


-- try to grant a task wish
function server.parseTask( string )
    local target = world.getObject( tonumber(string) )
    if target and target.selectable then
        target.selectable = false
        taskHandler.createTask(target)
    end
end


-- send the given message to all peers
function server.sendToPeers(message)
    -- if host is not set we are in startup phase and there are no
    -- clients to send things to
    if host and state == "ingame" then
        for i=1,host:peer_count() do
            local peer = host:get_peer(i)
            if peer:state() == "connected" then
                peer:send(message)
            end
        end
    end
end


-- inform about new char task
function server.sendNewCharTask(char)
    if char and char.task then
        server.sendToPeers("taskc "..char.id..","..char.task:toString())
    end
end


-- send update on objects
function server.updateObject(object)
    server.sendToPeers( "objup "..parser.parseObjectsToString( { object } ) )
end


-- inform about finished building
function server.sendBuildFinished(object)
    if object then
        server.sendToPeers("built "..object.id)
    end
end


-- inform clients to remove object with given id
function server.sendRemoveObject(id)
    server.sendToPeers("remob "..id)
end


-- inform clients to add given object
function server.sendAddObject(object)
    server.sendToPeers("plobj "..parser.parseObjectsToString( { object } ) )
end


-- send the whole game state
function server.sendGameState(peer)
    server.sendChunks(peer)
    server.sendObjects(peer)
    server.sendChars(peer)
end


-- send the current state of the lobby to the client
function server.sendLobbyInformation(peer)
    -- TODO: implement
end


-- send all chunks
function server.sendChunks(peer)
    
    for y,row in pairs(world.getChunks()) do
        for x,chunk in pairs(row) do
            
            peer:send("chunk " .. parser.parseChunkToString(x, y, chunk))
            
        end
    end
    
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
