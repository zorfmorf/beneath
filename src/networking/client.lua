--[[
    
    Handles network communcation to local or remote server
    
]]--

require "enet"

client = {}

local host = nil
local server = nil

function client.connect(address)
    
    host = enet.host_create()
    server = host:connect(address)
    
end


function client.getRTT()
    if server then 
        return server:round_trip_time()
    end
    return "n/a"
end


function client.service()
    if host then
        local event = host:service(0)
        while event do
            
            if event.type == "connect" then
                
                print("Connected to", event.peer)
                client.sendName("zorfmorf")
                
            elseif event.type == "receive" then
                
                if state == "lobby" then
                    
                    if event.data:sub(1, 6) == "lobby " then
                        
                        players = parser.parseLobbyInformation( event.data:sub(7) )
                        
                    end
                    
                else
                
                    if event.data:sub(1, 6) == "chunk " then
                        
                        print( "Received chunk data" )
                        client.parseChunk( event.data:sub(7) )
                        
                    elseif event.data:sub(1, 6) == "plobj " then
                        
                        print( "Received object data" )
                        client.parseObjects( event.data:sub(7) )
                        
                    elseif event.data:sub(1, 6) == "chars " then
                        
                        print( "Received char data" )
                        client.parseChars( event.data:sub(7) )
                        
                    elseif event.data:sub(1, 6) == "taskc " then
                        
                        print( "Received new char task", event.data:sub(7) )
                        client.parseTask( event.data:sub(7) )
                        
                    elseif event.data:sub(1, 6) == "remob " then
                        
                        print( "Received remove object", event.data:sub(7) )
                        client.parseRemoveObject( event.data:sub(7) )
                        
                    elseif event.data:sub(1, 6) == "built " then
                        
                        print( "Received build finished object", event.data:sub(7)  )
                        client.parseFinishBuild( event.data:sub(7) )
                        
                    elseif event.data:sub(1, 6) == "objup " then
                        
                        print( "Received update on object", event.data:sub(7)  )
                        client.parseObjectUpdate( event.data:sub(7) )
                    
                    elseif event.data:sub(1, 6) == "lobby " then
                        
                        players = parser.parseLobbyInformation( event.data:sub(7) )
                        
                    else
                        
                        print("Got message:", event.data, event.peer)
                        
                    end
                    
                end
                
            elseif event.type == "disconnect" then
                print("Disconnect:", event.data)
            end
            
            event = host:service(0)
            
        end
    end
end


function client.parsePlayerName( string )
    local id, name = parser.parseName(string)
    players[id].name = name
    print( "Player has name:", id, name)
end


function client.sendName(newname)
    server:send("setnm "..newname)
end


-- send build wish
function client.sendBuild(build)
    server:send("build "..build.__name..","..(-1)..","..build.l..","..build.x..","..build.y..","..build.xsize..","..build.ysize)
end


-- try to remove given object
function client.parseRemoveObject(string)
    local id = tonumber(string)
    if id and world.getObject(id) then
        world.removeObject(id)
    end
end


-- try to finish given building/object
function client.parseFinishBuild(string)
    local id = tonumber(string)
    if id and world.getObject(id) then
        local build = world.getObject(id)
        build.workleft = 0
        build:work(0.1)
        return
    end
    print( "Error: No building with id", id)
end


-- send task wish
function client.sendTask(object)
    server:send("taskw "..object.id)
end


-- Parse all chars received by server. TODO: catch errors
function client.parseChars(string)
    for i,char in pairs(parser.parseChars(string)) do
        world.addChar(char)
    end
end


-- Parse a new task for a char
function client.parseTask(string)
    local charid, task = parser.parseTask(string)
    local char = world.getChar(charid)
    if char then
        char:addTask(task)
    end
end


-- Parse all received objects. TODO: catch errors
function client.parseObjects(string)
    for i,object in pairs(parser.parseObjects(string)) do
        local result = world.addObject(object)
        
        if result then 
        
            if object:is(Field) then 
                object.placed = true
                object:generateImage() 
            end
        else
            print ( "Could not place parsed object", object.__name, object.id, object.l, object.x, object.y)
        end
    end
end


-- parse updates on one or more objects
function client.parseObjectUpdate(string)
    for i,object in pairs(parser.parseObjects(string)) do
        
        local actualObject = world.getObject(object.id)
        
        if actualObject then
            -- TODO: add all attributes that are interesting for this
            actualObject.ressources = object.ressources
        else
            print( "Got invalid update for", object.__name, object.id )
        end
        
    end
end


function client.disconnect()
    server:disconnect()
    host:flush()
    server = nil
    host = nil
    print(" Client shut down" )
end


function client.parseChunk(string)
    world.updateChunk(parser.parseChunk(string))
end
